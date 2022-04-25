<template>
  <div id="app">
    <el-container
        v-loading="loading"
        element-loading-text="正在链接区块，请稍后"
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
              <p>下方的画布为{{maxRow}}单位乘以{{maxCol}}单位大小</p>
              <p>每个单位的块为一个NFT</p>
              <p>每个没有主人的NFT玩家可以支付{{ethers.utils.formatEther(mintFee)}}BNB铸造，并且给予此nft一个颜色</p>
              <p>所有的nft不可随意转让，但是可以抢夺他人的nft</p>
              <p>抢夺他人的nft需要支付被抢夺玩家铸造或者抢夺费用的{{upTimes}}倍,并且给予此nft一个颜色</p>
              <p>被抢夺者会获得{{(upTimes-(upTimes-1)*managerFee100/100).toFixed(4)}}倍的补偿</p>
            </div>
          </el-col>

        </el-row>
        <el-row v-if="maxRow&&maxCol">

        </el-row>
      </el-main>
      <el-footer>

      </el-footer>
    </el-container>
  </div>
</template>

<script>
import {ethers} from "ethers";
import {abi} from './abis'

export default {
  name: 'app',
  data() {
    return {
      maxRow:0,
      maxCol:0,
      mintFee:0,
      upTimes:0,
      managerFee100:0,
      account: '',
      testChainId: '0x61',
      betFee: 0,
      maxPlayersOneTurn: 0,
      loudFee: 0,
      nowTurn: 0,
      manager: '',
      allTurnsData: [],
      allTurnsDataDeas: [],
      turn: 0,
      ethers:ethers,
      contractAddress: '0xC1283F9dD5C6c658079927886f616211c85cdfa3',
      rpc: 'https://data-seed-prebsc-2-s3.binance.org:8545/',
      loading: 1,
      tokensColor:[],
      tokensFee:[],
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
    deasData() {
      let deasdata = [];
      for (let i = this.allTurnsData.length; i >= 0; i--) {
        deasdata.push(this.allTurnsData[i])
      }
      return deasdata;
    },
    async bet(turn) {
      if (!this.checkAccount()) {
        return;
      }
      if (!this.checkChainId()) {
        return;
      }

      try {
        const Provider = await new ethers.providers.Web3Provider(window.ethereum)
        const signer = Provider.getSigner()
        const Contract = await new ethers.Contract(this.contractAddress, abi, signer);
        const tx = await Contract.bet(turn, {
          value: Contract.oneBetFee(),
          gasLimit: 500000,
          gasPrice: await Provider.getGasPrice()
        })
        const waitData = await tx.wait();
        console.log(waitData)
        if (waitData.status === 1) {
          this.$message({
            message: '下注成功！',
            type: 'success'
          });
        } else {
          this.$message({
            message: '下注失败请检查数据是否正确',
            type: 'warning'
          });
        }
      } catch (e) {
        this.$message({
          message: '下注失败请检查数据是否正确',
          type: 'warning'
        });
      }

    },
    async openAward() {
      if (!this.checkAccount()) {
        return;
      }
      if (!this.checkChainId()) {
        return;
      }
      try {
        const Provider = await new ethers.providers.Web3Provider(window.ethereum)
        const signer = Provider.getSigner()
        const Contract = await new ethers.Contract(this.contractAddress, abi, signer);
        const tx = await Contract.openAward({
          gasLimit: 500000,
          gasPrice: await Provider.getGasPrice()
        })
        const waitData = await tx.wait();
        if (waitData.status === 1) {
          this.$message({
            message: '开奖成功！',
            type: 'success'
          });
        } else {
          this.$message({
            message: '开奖失败请检查数据是否正确',
            type: 'warning'
          });
        }
      } catch (e) {
        this.$message({
          message: '开奖失败请检查数据是否正确',
          type: 'warning'
        });
      }
    },
    async overBet(turn) {
      if (!this.checkAccount()) {
        return;
      }
      if (!this.checkManager()) {
        return;
      }
      if (!this.checkChainId()) {
        return;
      }
      try {
        const Provider = await new ethers.providers.Web3Provider(window.ethereum)
        const signer = Provider.getSigner()
        const Contract = await new ethers.Contract(this.contractAddress, abi, signer);
        const tx = await Contract.overBet(turn, {
          gasLimit: 200000,
          gasPrice: await Provider.getGasPrice()
        })
        const waitData = await tx.wait();
        if (waitData.status === 1) {
          this.$message({
            message: '结束下注阶段成功！',
            type: 'success'
          });
        } else {
          this.$message({
            message: '结束下注阶段失败请检查数据是否正确',
            type: 'warning'
          });
        }
      } catch (e) {
        this.$message({
          message: '结束下注阶段失败请检查数据是否正确',
          type: 'warning'
        });
        console.log(e);
      }
    },
    //改用异步
    getAllData() {
      const Provider = new ethers.providers.JsonRpcProvider(this.rpc);
      const Contract = new ethers.Contract(this.contractAddress, abi, Provider);
      const that = this;
      Contract.maxRow().then(function (res){
        that.maxRow=res
      })
      Contract.maxCol().then(function (res){
        that.maxCol=res
      })
      Contract.mintFee().then(function (res){
        that.mintFee=res
      })
      Contract.upTimes().then(function (res){
        that.upTimes=res
      })
      Contract.managerFee100().then(function (res){
        that.managerFee100=res
      })
      Contract.getTokensFee().then(function (res){
        that.tokensFee=res
      })
      Contract.getTokensColor().then(function (res){
        that.tokensColor=res
      })
    },


    actionsToMessage: function (actionId) {
      const messages = [
        '未开启阶段',
        '开启阶段（可以投注）',
        '投注结束，等待开奖阶段',
        '已结束阶段'
      ]
      return messages[actionId];
    },
    linkMessage: function () {
      return this.account ? this.account : '链接钱包'
    },
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
    },
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
    },
    checkAccount: function () {

      if (!this.account) {
        this.$message({
          message: '请先链接钱包',
          type: 'warning'
        });
        return false
      }
      return true;
    },
    checkManager: function () {
      if (this.account.toUpperCase() !== this.manager.toUpperCase()) {

        this.$message({
          message: '您不是管理员没有权限操作',
          type: 'warning'
        });
        return false;
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
