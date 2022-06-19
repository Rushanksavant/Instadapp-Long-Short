# Instadapp Tasks

## Task1
### Long/Leverage :

A leveraged position on an asset is taken when it is expected for the asset price to go up sooner or later. Leveraged or Long position is basically buying more of that asset before, and selling it after the price rise, hence making a profit on price difference. 

## Using Flash loans:
- Let's say you have 100$ worth ETH in your wallet, and it's expected that for ETH price to rise in comming days
- You take a flash loan of 200$ to 3x your collateral
- You deposit the total 300$ worth ETH in Coumpound protocol
- Compund allows you to borrow against the asset you deposit, hence you borrow 200$ worth DAI stable coin(i.e 200 DAI) against your deposit.
- Now you swap this (200 DAI) on Uniswap for ETH. And repay your loan.
- Doing this you have created a leveraged position of 3x.
- And your debt with compound is 200$ (this will remain contant since DAI is stable)
- So after a few days, the ETH price increased by 10%(say), hence your position will now worth 330$
- Hence your net profit: 330 - 200(debt) - 100(original holding) = 30$
- But if you holded the ETH as it is, it would have given you just 10$ profit.

## Using only Compound:
- Let's say you have 100$ worth ETH in your wallet, and it's expected that for ETH price to rise in comming days
- You deposit your 100$ worth ETH in Coumpound protocol
- Compund allows you to borrow against the asset you deposit, hence you borrow 75$ worth DAI stable coin(i.e 75 DAI) against your deposit.
- Now you swap this (75 DAI) on Uniswap for ETH. And deposit it again in Compound.
- And then repeat this a few times:
    - borrow 131.25 (75% of 175) DAI on Compound, swap it for ETH on uniswap and deposit the ETH in Compound
    - Doing this until the collaterl becomes >= 3x (i.e 300$)
- And your debt with compound will be >= 200$ (this will remain contant since DAI is stable)
- So after a few days, the ETH price increased by 10%(say), hence your position will now worth >=330$
- Hence your net profit: 330 - 200(debt) - 100(original holding) >= 30$
- But if you holded the ETH as it is, it would have given you just 10$ profit.

**Work:**

- The borrowing is done based on the collateral factor of the asset (75% for ETH)
- We first calculate the number of times we need to borrow for leveraging our collateral to 3x, and the corresponding amount for each borrow.
- We store the number of borrows and amounts for each borrow in state variables
- After every borrow the amount is deposited back in Compound as collateral (exactly like the example above)
- The spells are written to deposit and borrow for each amount calculated before
- Then the spells are cast