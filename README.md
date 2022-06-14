# Instadapp Tasks

## Task1
### Long/Leverage :

A leveraged position on an asset is taken when it is expected for the asset price to go up sooner or later. Leveraged or Long position is basically buying more of that asset before, and selling it after the price rise, hence making a profit on price difference. 

**Using Compound:**

- Let's say you have 100$ worth ETH in your wallet, and it's expected that for ETH price to rise in comming days
- You deposit your 100$ worth ETH in Coumpound protocol
- Compund allows you to borrow against the asset you deposit, hence you borrow 50$ worth DAI stable coin(i.e 50 DAI) against your deposit.
- Now you swap this (50 DAI) on Uniswap for ETH. And deposit it again in Compound.
- And then repeat this a few times:
    - borrow 25 DAI on Compound, swap it for ETH on uniswap and deposit the ETH in Compound 
    - borrow 12.5 DAI on Compound, swap it for ETH on uniswap and deposit the ETH in Compound 
- Doing this you have created a 3x leveraged position, of 100 + 50 + 25 + 12.5 = 187.5$ worth ETH. 
- And your debt with compound is 50 + 25 + 12.5 = 87.5$ (this will remain contant since DAI is stable)

- So after a few days, the ETH price increased by 10%(say), hence your position will now worth 206.25$, and debt is still worth 87.5$
- Hence your net profit: 206.25 - 87.5(debt) - 100(original holding) = 18.75$
- But let's say you just holded the 100$ worth ETH in your wallet, it would have been a 10$ profit then.  
