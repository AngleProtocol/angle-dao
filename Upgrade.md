# Upgrade

## Layout

You can first check the storage layout differences with `vyper contracts/dao/veANGLE.vy -f layout` and `vyper contracts/dao/veANGLE-old.vy -f layout`

## Upgrade

- first deploy the new contract using DeployVeAngleScript contract.

- Then go to angle-governance repository and run the UpgradeVeAngleScript script.
