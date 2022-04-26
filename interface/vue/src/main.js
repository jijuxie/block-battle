import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import './plugins/element.js'
import vcolorpicker from 'vcolorpicker'
Vue.config.productionTip = false
Vue.use(vcolorpicker)
new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')


// Initialize ethers store
store.dispatch('ethers/init')
