# Welcome to Adhat.io!

## Story 001

### Context

 UPLOAD -> SALE -> BUY

### Actors

 1. Alice :  I have a valuable content which I will upload to the platform. Now I want to put it on sale.
 2. Bob : I buyer I want to buy that content. So I came to adhat market place to buy it. I saw Alice is selling a content which I am interested in. I want the owner ship of the content to be delivered to me.

 Alice  : content Owner
 Bob : Buyer 1

 *Note : Same story can be applied to car owner ship, flat ownership etc.*

### Test Cases Result

![story001](https://github.com/hypermine-bc/adhat-contracts/blob/master/test-cases-assets/test_story001.png)


## Story 002

### Context

 UPLOAD -> SALE -> BUY -> RESALE -> TRACK

### Actors

 1. Alice :  I have a valuable content which I will upload to the platform. Now I want to put it on sale.
 2. Bob : I buyer I want to buy that content. So I came to adhat market place to buy it. I saw Alice is selling a content which I am interested in. I want the owner ship of the content to be delivered to me. Once I used the content, I want to resell it.
 3. Kate : I am Kate, and I want to buy a content but I want it for cheap price. I can buy from Bob since he is selling the content for cheaper price
 
 Alice  : content Owner
 Bob : Buyer 1
 Kate: Buyer 2

 *Note : Same story can be applied to car owner ship, flat ownership etc.*

### Test Cases Result

![story002](https://github.com/hypermine-bc/adhat-contracts/blob/master/test-cases-assets/test_story002.png)
 

# Installation and Execution

1. Install truffle
    
    ` npm i -g truffle  `

2. Update node modules

    ` npm i`

3. Run truffle in develop mode 

    ` truffle develop `

    truffle console will be open now

4. Compile contracts inside truffle console

    ` compile `

5. Execute test cases inside truffle console

    ` test `

