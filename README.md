# <a name="rn"/>Smart Contracts
Asset, Node, and Digital Rewards Engine Whatchamacallit

## Proof-of-Merit 
Nodes are rewarded based on the measured, economic utility of the good or service represented by the node. The main characteristics of PoM are:
* Asset creators assign URIs to their assets
* Asset metrics are collected by witness nodes (proxies)
* The asset creator allows their URIs to be tokenized by others

A rewards engine divvies out rewards tokens to URI NFTs in proportion to the NFTs' measured performance. Usage is measured in most cases by sending service request through a proxy, e.g. the RUDI and PBR. Proof-of-Authority is used to determine who is allowed to publish metrics. In A.N.D.R.E.W., a DAO is used to determine which performers receive rewards and in what proportion.

The rewards algorithm must be agreed upon by the reward providers. In the case of the A.N.D.R.E.W., the community is endowed with a supply of network tokens, thus the community is a rewards provider. To solve the problem of consensus about how this endowment is appropriated, a DAO is formed. The endowment is stored in a smart contract escrow account, and released to a group of trustees elected by the community. The trustee determine the rewards algorithms and are responsible for payment distribution. These trustees are required to distribute 100% of the tokens they collect from the escrow (however, this term is not captured in the smart contract). An Authority node holds the right to veto the community's decision to add or remove a trustee.

## The DAO

The A.N.D.R.E.W. employs a [democratic governance model, with representative aspects](https://medium.com/organizer-sandbox/liquid-democracy-true-democracy-for-the-21st-century-7c66f5e53b6f), and features a Proof-of-Authority monitor. Anyone can propose a trustee address, so long as they stake the amount of network tokens stipulated by the Authority node. Network tokens are staked to the token contract in exchange for voting credits in a 1-to-1 ratio. The Authority decides the quorum for an election, given as a percentage of the electorate (the circulating token supply).

A voter may delegate her credits to another voter. The delegation chain limit is 10.

[![alt text](https://docs.google.com/drawings/d/e/2PACX-1vTDVHeGDzBcW2gOgoj9BqclXmHudnYGF1FTRePd5GEziKtnDkxrA5A0EKfM7C0XQgPJc5e_Szx07UHD/pub?w=1670&h=1113)](https://docs.google.com/drawings/d/1cKvEFcbBnGS0QmyV0PVg0zDpJQcHCUpu_wcJwWojOqU/edit?usp=sharing)

### Penalties

The Authority must authorize the election before the decision can be executed. If the Authority closes an unauthorized election, the sponsor's deposit is confiscated by the Authority to dispense with it as they choose. Otherwise, the sponsor's deposit is refunded. Voters may claim their deposited tokens only after the election has been closed.

### Ballot

Each user is allowed to claim one ballot per account, and must stake tokens to receive the corresponding number of vote credits. When these credits are delegated to users of high reputation, the voter receives reputation points in proportion to the reputation of the delegate (but these terms are not captured in the DAO contract). Furthermore, the delegate receives reputation points if they option they choose goes on to win the election. Reputation can then be used to infuse the member's IDNs with enhanced characteristics (e.g. reward-earning power). This feature is meant to balance power between the plutocrats and meritocrats. The DAO's plutocrats will require the merit and reputation of the community's most devoted and active members if they wish to maximize their earnings, and delegates will need to be responsive to their constituiency if they wish to continue being delegated.

Each ballot represents a question and a list of possible answers, where each answer is associated with a binary response. More specifically, a ballot is a list of choices where each choice is an arbitrary noun/verb pair. E.g.

```
How should the Science IDN issue be addressed?

a. Refunds should be issued from the Science Guild's trust
b. IDNs should be minted and distributed to the complainants free-of-charge
c. No action should be taken by the community
```

Each answer corresponds to a blockchain address, thus, the options may identify persons or organizations, or may be used as identifiers for subjects or other types of individuals. The answer's ```action_type``` determines what happens when the decision is executed by the contract. For action types ```1``` and ```0```, the address is assigned as trustee, or relieved of trustee duty, respectively. When voters cast their ballots, they may submit a boolean value to assign to one choice, per address. Thus, a voter may make a decision on multiple choices, or decide on a single choice multiple times, so long as they use multiple addresses each time when claiming their ballot.

In the case of trustees, if a nominee receives more yay's than nay's, they are given trusteeship. In all other cases, the interpretation and execution of the election results must be handled off-chain.

### Authority

The role of the Authority node is to initialize polls and authorize community decisions. They serve as a control against malicious, unacceptable, or invalid proposals being executed. The Authority is not elected, but is instead a multisig wallet address appointed by the DAO initiator. When the token is deployed, a list of failsafe Authority addresses must be submitted. At anytime during the token distribution, a trustee can replace the current Authority with any of the failsafes. The failsafe list is immutable.

### Trustee

In the A.N.D.R.E.W. design, a trustee is intended to be a smart contract with logic for rewarding the IDN categories under its purview. These contracts must coordinate their withdraws from the parent escrow in accordance with rules agreed upon by the community. The community is also responsible for passing the specifications to which trustees must adhere. Below are a few examples:

* The contract must be a token dispensary with withdraw permissions given to IDN owners and/or trustees of an escrow within the dispensary
* The amount each IDN owner is allowed to withdraw is equal to the earnings of the IDN since the last withdrawal, or if trustees are assigned, then the trustee may withdraw the balance of the contract's escrow
* The contract must withdraw from the parent escrow at a schedule stipulated by the parent escrow's guild (this term is not captured in the root escrow's contract)
* The contract must allow for voting by those who hold IDNs under the escrow's purview
* The contract must self destruct if the destroy function is invoked by an anonymous caller and no poll is active and the contract is not a trustee

In this way, guilds can be formed to manage the sub-appropriation of the community's endowment.



