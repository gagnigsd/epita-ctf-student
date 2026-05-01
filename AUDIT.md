# AUDIT.md — FairCasino CTF

## Auteur
Gagni Saer DIOP — EPITA 2027

## Adresses
- Wallet (EOA) : `0x8E26A7A22DeD5E9e3F291bd3adEdcE9679f747E8`
- Contrat Drainer : `0x0006021Aa5c88c95C500744624987166F5A76A14`
- Contrat cible : `0xed5415679D46415f6f9a82677F8F4E9ed9D1302b`

## Transactions (3 strikes)
| Strike | Round | Hash |
|--------|-------|------|
| 1 | 50 | `0xd19f8bd300183ff9ed8cb3689b4e303d6ad295b2108ca24f8e745588a8ac0bf2` |
| 2 | 51 | `0xd29c9903818a4ac27a0de8a0dbf4122bf66667dfb4ef57e09793aa2507c2fa5b` |
| 3 | 52 | `0x50f70cbfe1994302625341c7461a5391e3e7b81a33657b95ecb5cd29518e948a` |

## Vulnérabilités identifiées

### 1. Résultat déterministe
Le nombre gagnant est calculé avec des paramètres tous lisibles publiquement :
- `secretTarget` : variable `private` lisible via `eth_getStorageAt` (slot 5)
- `gameSalt` : variable `immutable` extraite du bytecode
- `price` : oracle Chainlink public
- `currentRound` : variable publique

### 2. Nonce minable (signature 0xBEEF)
La vérification exige que les 2 derniers octets du hash soient `0xBEEF`.
Probabilité : 1/65536 — bruteforceable en millisecondes off-chain.

## Stratégie d'attaque

1. Lecture des slots de stockage via `cast storage`
2. Extraction de `gameSalt` depuis le bytecode
3. Calcul off-chain du `winningNumber` et du `nonce` valide en Python
4. Appel de `Drainer.attack(winningNumber, round, nonce)` avec 0.01 ETH
5. Distribution atomique 50/30/20 dans la même transaction

## Défis techniques

- **Slots décalés** : Context.sol ajoute 4 variables, décalant les slots de FairCasino de +4
- **Gas excessif** : boucle while on-chain depasse la limite — solution : calcul off-chain
- **encodePacked vs encode** : eth_abi.encode produit un padding incompatible — réécriture manuelle
