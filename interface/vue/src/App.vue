<template>
  <div id="app">
    <el-container
        v-loading="loading"
        :element-loading-text="loadingMessage"
        element-loading-spinner="el-icon-loading"
        element-loading-background="rgba(0, 0, 0, 0.8)">
      <el-header style="background-color:#00FFFF;">
        <el-button type="warning" round @click="linkAccount()">{{ linkMessage() }}</el-button>
      </el-header>
      <el-main v-if="!loading">
        <el-row>
          <el-col :span="24">
            <div>
              <h1>BlockBattle（币安测试网）</h1>
              <p>下方的画布为{{ maxRow }}单位乘以{{ maxCol }}单位大小</p>
              <p>每个单位的块为一个NFT</p>
              <p>每个没有主人的NFT玩家可以支付{{ ethers.utils.formatEther(mintFee) }}BNB铸造，并且给予此nft一个颜色</p>
              <p>所有的nft不可随意转让，但是可以抢夺他人的nft</p>
              <p>抢夺他人的nft需要支付被抢夺玩家铸造或者抢夺费用的{{ upTimes }}倍,并且给予此nft一个颜色</p>
              <p>被抢夺者会获得{{ (upTimes - (upTimes - 1) * managerFee100 / 100).toFixed(4) }}倍的补偿</p>
            </div>
          </el-col>

        </el-row>
        <el-row v-if="maxRow&&maxCol&&myTokens"
                style=" height: 1000px; width: 1000px; margin-left: auto;margin-right: auto; overflow: hidden;background-color:#f3a3a3; display: flex;flex-wrap: wrap">
          <el-popover v-for="(block ,index) in allBlock" :key="index"
                      placement="top"
                      width="160"
                      trigger="hover">

            <h2>#{{ index }}</h2>
            <h5>nft信息：</h5>
            <p>拥有者：{{ block.address ? block.address : '本nft未被铸造' }}</p>
            <p v-if="block.who!==0">抢夺所需价格：{{ethers.utils.formatEther(block.fee*upTimes)}}</p>
            <p>点击选择颜色：
              <colorPicker v-model="color"/>
            </p>

            <div style="text-align: right; margin: 0">
              <el-button v-if="block.who===0" size="mini" type="primary" @click="mint(index)">铸造</el-button>
              <el-button v-if="block.who!==0" type="danger" size="mini" @click="loot(index,block.fee)">抢夺</el-button>
            </div>
            <div style="box-sizing:border-box;" slot="reference"
                 :style="[{width:blockItems+'px'}, {height:blockItems+'px'},{background:int10ToColor(block.color) }]"
                 :class="whoBlockClass(block.who)"></div>
          </el-popover>
        </el-row>
      </el-main>
      <el-footer>

      </el-footer>
    </el-container>
  </div>
</template>

<style>
.dCont .content-container {
  display: flex;
  flex-wrap: wrap;

}

.noOwnerBlock {
  border: 2px solid #ffffff;
}

.noSelfBlock {
  border: 2px solid #ff0000;
}

.selfBlock {
  border: 2px solid #3bff00;
}
</style>
<script>
import {ethers} from "ethers";
import {abi} from './abis'

// import VueDragResize from 'vue-drag-resize';

export default {
  name: 'app',
  data() {
    return {
      color: '#ff0000',
      maxRow: 0,
      maxCol: 0,
      mintFee: 0,
      upTimes: 0,
      managerFee100: 0,
      loadingMessage: '',
      account: '',
      testChainId: '0x61',
      ethers: ethers,
      contractAddress: '0xB05b8Af078722D8D85d853DbDFeb08a71Ab4f0ff',
      rpc: 'https://data-seed-prebsc-2-s3.binance.org:8545/',
      loading: 1,
      tokensColor: [],
      tokensFee: [],
      width: 10,
      height: 10,
      top: 0,
      left: 0,
      blockItems: 100,
      allBlock: [],
      myTokens: [],
    }
  },
  components: {},
  async mounted() {
    this.loading = 0;
    this.getAllData();
    const that = this;
    setInterval(function () {
      that.getAllData()
    }, 3000);
  },
  methods: {
    async mint(index) {
      if(!this.checkChainId()){
        return;
      }
      if(!this.checkAccount()){
        return;
      }
      this.loading = 0;
      this.loadingMessage = '正在铸造，请稍后。。。。'


      try {
        const Provider = await new ethers.providers.Web3Provider(window.ethereum)
        const signer = Provider.getSigner()
        const Contract = await new ethers.Contract(this.contractAddress, abi, signer);
        // console.log()
        let tx = await Contract.mint(index, '0x'+this.color.substring(6),
            {
              value: this.mintFee,
              gasLimit: 500000,
              gasPrice: await Provider.getGasPrice()
            }
        );
        let res = await tx.wait();
        if (res.status === 1) {

          this.$message({
            message: '铸造成功！',
            type: 'success'
          });
        } else {

          this.$message({
            message: '铸造失败，请检查数据，或者有人抢先铸造',
            type: 'error'
          });
        }
      } catch (e) {
        this.$message({
          message: '铸造失败，请检查数据，或者有人抢先铸造',
          type: 'error'
        });
      }
      this.loading = 1;
    },
    async loot(index,fee) {
      if(!this.checkChainId()){
        return;
      }
      if(!this.checkAccount()){
        return;
      }
      const Provider = await new ethers.providers.Web3Provider(window.ethereum)
      const signer = Provider.getSigner()
      const Contract = await new ethers.Contract(this.contractAddress, abi, signer);
      this.loading = 0;
      this.loadingMessage = '正在抢夺，请稍后。。。。'
      try {
        let tx = await Contract.loot(index, parseInt(this.color, 10),
            {
              value:  fee.mul(this.upTimes),
              gasLimit: 500000,
              gasPrice: await Provider.getGasPrice()
            }
        );
        let res = await tx.wait();
        if (res.status === 1) {
          this.loading = 1;
          this.$message({
            message: '抢夺成功！',
            type: 'success'
          });
        } else {
          this.loading = 1;
          this.$message({
            message: '抢夺失败，请检查数据，或者有人抢先铸造',
            type: 'error'
          });
        }

      } catch (e) {
        console.log(e)
        this.loading = 1;
        this.$message({
          message: '抢夺失败，请检查数据，或者有人抢先铸造',
          type: 'error'
        });
      }

    },
    whoBlockClass(index) {
      if (index === 0) {
        return {noOwnerBlock: true}
      } else if (index === 1) {
        return {noSelfBlock: true}
      } else {
        return {selfBlock: true}
      }
    },
    resize(newRect) {
      this.width = newRect.width;
      this.height = newRect.height;
      this.top = newRect.top;
      this.left = newRect.left;
    },
    //改用异步
    getAllData() {
      const Provider = new ethers.providers.JsonRpcProvider(this.rpc);
      const Contract = new ethers.Contract(this.contractAddress, abi, Provider);
      const that = this;
      if (!that.maxRow) {
        Contract.maxRow().then(function (res) {
          that.maxRow = res
        })
      }
      if (!that.maxCol) {
        Contract.maxCol().then(function (res) {
          that.maxCol = res
        })
      }
      if (!that.mintFee) {
        Contract.mintFee().then(function (res) {
          that.mintFee = res
        })
      }
      if (!that.upTimes) {
        Contract.upTimes().then(function (res) {
          that.upTimes = res
        })
      }
      if (!that.managerFee100) {
        Contract.managerFee100().then(function (res) {
          that.managerFee100 = res
        })
      }

      Contract.getTokensFee().then(function (res) {
        that.tokensFee = res

      })
      Contract.getTokensColor().then(function (res) {
        that.tokensColor = res
      })
      Contract.getMyTokens().then(function (res) {
        that.myTokens = res
        that.reAllBlock()
      })
    },
    int10ToColor(argb) {
      var rgb = [];
      rgb[0] = (argb & 0xff0000) >> 16;
      rgb[1] = (argb & 0xff00) >> 8;
      rgb[2] = (argb & 0xff);
      return "rgb(" + rgb[0] + "," + rgb[1] + "," + rgb[2] + ")";
    },
    reAllBlock() {
      if (this.maxRow && this.maxCol && this.tokensFee && this.tokensColor) {
        for (let x = 0; x < this.maxRow; x++) {
          for (let y = 0; y < this.maxRow; y++) {
            if (!this.allBlock[this.maxRow * x + y]) {
              this.allBlock[this.maxRow * x + y] = {}
            }
            this.allBlock[this.maxRow * x + y].row = x;
            this.allBlock[this.maxRow * x + y].col = y;
            this.allBlock[this.maxRow * x + y].color = this.tokensColor[this.maxRow * x + y] ? this.tokensColor[this.maxRow * x + y] : 0;
            this.allBlock[this.maxRow * x + y].fee = this.tokensFee[this.maxRow * x + y] ? this.tokensFee[this.maxRow * x + y] : 0;
            this.allBlock[this.maxRow * x + y].who = this.allBlock[this.maxRow * x + y].fee ? this.myTokens[this.maxRow * x + y] ? 2 : 1 : 0;
          }
        }
      }
    }
    ,
    linkMessage: function () {
      return this.account ? this.account : '链接钱包'
    }
    ,
    linkAccount: async function () {
      if (typeof window.ethereum !== 'undefined') {
        console.log('MetaMask is installed!');
        this.account = (await window.ethereum.request({method: 'eth_requestAccounts'}))[0];
        console.log(this.account)
        this.checkChainId()
      } else {
        this.$message({
          message: '您还没有安装MetaMask,请先安装小狐狸之后再试',
          type: 'warning'
        });
      }
    }
    ,
    checkChainId: function () {
      console.log(window.ethereum.chainId)
      if (this.testChainId !== window.ethereum.chainId) {
        this.$message({
          message: '请切换到币安测试链，链id：0x61',
          type: 'warning'
        });
        return false
      }
      return true;
    }
    ,
    checkAccount: function () {

      if (!this.account) {
        this.$message({
          message: '请先链接钱包',
          type: 'warning'
        });
        return false
      }
      return true;
    }
  },
}
</script>

<style>
body {
  margin: 0;
  padding: 0;
}

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;

}
</style>
