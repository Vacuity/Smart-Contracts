# <a name="rn"/>A.N.D.R.E.W.
Asset, Node, and Digital Rewards Engine Whatchamacallit

## Proof-of-Performance 
Nodes are rewarded based on the measured, economic utility of the good or service represented by the node. The main characteristics of PoP are:
* Asset creators assign URIs to their assets
* Metrics are collected for the assets
* A communal resource pool is allocated
* The asset creator allows their URIs to be tokenized by others

A rewards engine divvies out the token supply to URI NFTs in proportion to the NFTs' measured performance. Usage is measured in most cases by sending service request through the RUDI and PBR proxies. Proof-of-Authority is used to determine who is allowed to publish metrics, while a DAO is used to determine which performers receive rewards and in what proportion.

There must be consensus about how the endowment is appropriated, that is, the rewards algorithm must be agreed upon by the reward providers. In the case of the A.N.D.R.E.W., the community is endowed supply of network tokens, thus the community is a rewards provider. The endowment is stored in a smart contract escrow account, and released to a group of trustees elected by the community. An Authority node holds the right to veto the community's decision to add or remove a trustee.

## The DAO

The A.N.D.R.E.W. DAO model uses a democratic governance model, with representative aspects, and features a Proof-of-Authority monitor. Anyone can propose a trustee address, so long as they stake the amount of network tokens stipulated by the Authority node. Network tokens are staked to the token contract in exchange for voting credits, in a 1-to-1 ratio. The Authority decides the quorum for an election, given as a percentage of the electorate (the circulating token supply).

A voter may delegate her credits to another voter. The delegation chain limit is 10.

![alt text](https://docs.google.com/drawings/d/e/2PACX-1vTDVHeGDzBcW2gOgoj9BqclXmHudnYGF1FTRePd5GEziKtnDkxrA5A0EKfM7C0XQgPJc5e_Szx07UHD/pub?w=1463&h=1112)

### Penalties

The Authority must authorize the election before the decision can be executed. If the Authority closes an unauthorized election, the sponsor's deposit is confiscated by the Authority to dispense with it as they choose. Otherwise, the sponsor's deposit is refunded. Voters may claim their deposited tokens only after the election has been closed.
