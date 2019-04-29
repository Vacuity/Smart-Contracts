# <a name="rn"/>A.N.D.R.E.W.
Asset, Node, and Digital Rewards Engine Whatchamacallit

## Proof-of-Performance 
Nodes are rewarded based on the measured, economic utility of the good or service represented by the node. The main characteristics of PoP are:
* Asset creators assign URIs to their assets
* Metrics are collected for the assets
* The asset creator allows their URIs to be tokenized by others

A rewards engine divvies out rewards tokens to URI NFTs in proportion to the NFTs' measured performance. Usage is measured in most cases by sending service request through a proxy, e.g. the RUDI and PBR. Proof-of-Authority is used to determine who is allowed to publish metrics. In A.N.D.R.E.W., a DAO is used to determine which performers receive rewards and in what proportion.

The rewards algorithm must be agreed upon by the reward providers. In the case of the A.N.D.R.E.W., the community is endowed with a supply of network tokens, thus the community is a rewards provider. To solve the problem of consensus about how this endowment is appropriated, a DAO is formed. The endowment is stored in a smart contract escrow account, and released to a group of trustees elected by the community. The trustee determine the rewards algorithms and are responsible for payment distribution. These trustees are required to distribute 100% of the tokens they collect from the escrow (however, this term is not captured in the smart contract). An Authority node holds the right to veto the community's decision to add or remove a trustee.

## The DAO

The A.N.D.R.E.W. employs a democratic governance model, with representative aspects, and features a Proof-of-Authority monitor. Anyone can propose a trustee address, so long as they stake the amount of network tokens stipulated by the Authority node. Network tokens are staked to the token contract in exchange for voting credits in a 1-to-1 ratio. The Authority decides the quorum for an election, given as a percentage of the electorate (the circulating token supply).

A voter may delegate her credits to another voter. The delegation chain limit is 10.

[![alt text](https://docs.google.com/drawings/d/e/2PACX-1vTDVHeGDzBcW2gOgoj9BqclXmHudnYGF1FTRePd5GEziKtnDkxrA5A0EKfM7C0XQgPJc5e_Szx07UHD/pub?w=1670&h=1113)](https://docs.google.com/drawings/d/1cKvEFcbBnGS0QmyV0PVg0zDpJQcHCUpu_wcJwWojOqU/edit?usp=sharing)

### Penalties

The Authority must authorize the election before the decision can be executed. If the Authority closes an unauthorized election, the sponsor's deposit is confiscated by the Authority to dispense with it as they choose. Otherwise, the sponsor's deposit is refunded. Voters may claim their deposited tokens only after the election has been closed.

### Ballot

Each user is allowed to claim one ballot per account, and must stake tokens to receive the corresponding number of vote credits. When these credits are delegated to users of high reputation, the voter receives reputation points in proportion to the reputation of the delegate (but these terms are not captured in the DAO contract). Reputation can then be used to infuse the member's IDNs with enhanced characteristics (e.g. reward-earning power).

Each ballot represents a question and a list of possible answers, where each answer is associated with a binary response. E.g.

```
How should the Science IDN issue be addressed?

a. Refunds should be issued from the Science Guild's trust
b. IDNs should be minted and distributed to the complainants free-of-charge
c. No action should be taken by the community
```

Each answer corresponds to a blockchain address, thus, the options may represent persons or organizations. The answer's ```type``` determines what happens when the decision is executed by the contract. For types ```1``` and ```0```, the address is assigned as trustee, or relieved of trustee duty, respectively. When voters cast their ballots, they may submit a boolean value to assign to one choice, per address. Thus, a voter may make a decision on multiple choices, or decide on a single choice multiple times, so long as they use multiple addresses each time when claiming their ballot.

In the case of trustees, if a nominee receives more yay's than nay's, they are given trusteeship. In all other cases, the interpretation and execution of the election results must be handled off-chain.
