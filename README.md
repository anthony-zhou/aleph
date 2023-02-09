# Aleph

This is my implementation of the Aleph blockchain in Elixir. 

The system, in its curent state, allows you to input transaction data that is replicated in a DAG structure across the nodes.

Note that the system lacks many of Aleph's critical security features. It's more useful to treat this as a simplified proof-of-concept for a DAG-based consensus protocol than as a full-fledged blockchain system. 

## Testing the network

First, run `mix deps.get` to get dependencies. 

Then, run `mix test` to see if everything works. 

All the magic happens in the module `lib/driver.ex`, which starts a test network with `node_count` nodes and inputs fake data for `rounds` rounds. Example usage can be found in `test/driver_test.ex`. 

## Simplifications

I focused mainly on implementing the DAG (directed acyclic graph) and reliable broadcast protocols, while ignoring reliable transaction ordering. For this subset of the Aleph features, here are the simplifications I made: 

Instead of erasure encoding, I've made dummy erasure encoding, which just chunks the JSON-ified data across nodes and recombines the chunks. This means the nodes need to receive all N messages to reconstruct the data object. An actual fault-tolerant system would use erasure encoding (e.g. [Reed-Solomon](https://en.wikipedia.org/wiki/Reed%E2%80%93Solomon_error_correction)) with tolerance to *f* errors, where N = 3*f* + 1.

Instead of using public keys and signatures, I'm just using the node IDs to identify Unit creators and trusting that nodes are not impersonating other nodes. This can be fixed simply by initializing keypairs at the time of DAG initialization. 

Instead of using distributed nodes, I'm just running the nodes on separate processes on the same device. This makes testing a lot easier, and it's relatively straightforward to adapt the network model to node-to-node communication. 

## References

[Original Aleph paper](https://arxiv.org/pdf/1908.05156.pdf)
