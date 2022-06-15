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
- Doing this you have created a leveraged position, of 100 + 50 + 25 + 12.5 = 187.5$ worth ETH.
- And your debt with compound is 50 + 25 + 12.5 = 87.5$ (this will remain contant since DAI is stable)


- So after a few days, the ETH price increased by 10%(say), hence your position will now worth 206.25$
- Hence your net profit: 206.25 - 87.5(debt) - 100(original holding) = 18.75$
- But if you holded the ETH as it is, it would have given you just 10$ profit.

**Work:**
- The borrowing is done based on the collateral factor of the asset (we were just borrowing 50% in above example)
- We first calculate the number of times we need to borrow for leveraging our collateral to 3x, and the corresponding amount for each borrow. 
    - We store the number of borrows and amounts for each borrow in state variables
- After every borrow the amount is deposited back in Compound as collateral (exactly like the example above)
    - The spells are written to deposit and borrow for each amount calculated before
    - Then the spells are cast


