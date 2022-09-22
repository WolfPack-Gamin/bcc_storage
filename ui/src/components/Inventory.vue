<template>
  <div style="position: relative;">
    <div v-if="dropzone" class="activedrop" :id="type">
    </div>
    <div class="inventory">
      <h1>{{ header }}</h1>
      <hr/>
      <h3 v-if="!compinventory || compinventory.length <= 0">Drag an item to add it to this inventory</h3>
      <div class="items">
          <Tile :dev="dev" :disabled="disabled" @toggleActive="toggleActive" @onmoved="handleMoved" :sid="type" :index="index" :item="item" v-for="(item, index) in compinventory" :key="'inv'+index" @mouseover="activeItem = item" @mouseleave="activeItem = {}"></Tile>
      </div>
    </div>
    <Preview :alignLeft="type == 'str'" :activeItem="activeItem"/>
  </div>
</template>

<script>
import Preview from './Preview.vue'
import Tile from './Tile.vue'


export default {
  name: 'Inventory',
  props: {
    header: { type: String, requred: false, default: 'Satchel' },
    type: { type: String, required: true },
    inventory: { type: Object, requred: false, default: [] },
    dropzone: { type: Boolean, required: false, default: false },
    dev: { type: Boolean, required: false, default: false },
    disabled: { type: Boolean, required: false, default: false }
  },
  data () {
    return {
      activeItem: {},
      compinventory: [],
    }
  },
  emits: ['onmoved'],
  components: {
    Preview,
    Tile,
    Tile
  },
  watch: {
    inventory(data) {
      this.compinventory = data
    }
  },
  methods: {
    handleMoved(mv) {
      this.$emit('onmoved', {
          data: mv.data,
          to: mv.to,
          from: mv.from
      })
    },
    toggleActive(a) {
      this.$emit('toggleActive', { active: a, from: this.type })
    },
    removeByLabel(arr, label) {
      const requiredIndex = arr.findIndex(el => {
          return el.label === String(label);
      });
      if(requiredIndex === -1){
          return false;
      };
      return !!arr.splice(requiredIndex, 1);
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.inventory {
  position: relative;
  background-image: url(../assets/bg.png);
  background-repeat: no-repeat;
  background-position: center;
  background-size: 100% 100%;
  padding: 14px;
  border-radius: 2px;
  margin-top: 30px;
  overflow: hidden;
  overflow-y: auto;  
  height: 60vh;
}

h1  {
  text-align: center;
  margin-top: -10px;
  margin-bottom: 0px;
  user-select: none;
}

h3 {
  text-align: center;
  margin: 0px;
}

hr {
  margin-top: 0;
}

.activedrop {
  position: absolute;
  top: 90px;
  left: 10px;
  right: 10px;
  bottom: 10px;
  border-radius: 2px;
  border: 10px solid red;
  opacity: .5;
  z-index: 99999
}

.items {
  display: grid;
  grid-template-columns: 20% 20% 20% 20%;
  gap: 10px;
  justify-content: space-evenly;
  justify-items: center;
  align-content: space-evenly;
  align-items: center;
}

.item {
  background-color: #948A8A;
  /* padding: 20px; */
  text-align: center;
  overflow: hidden;
  position: relative;
  border-radius: 2px;
  z-index: 9999;
}

.filter {
  background-color: rgba(143, 70, 70, 0.618);
  transition: all .3s;
  position: absolute;
  left: 0;
  right: 0;
  top: 0;
  bottom: 0;
  opacity: 0;
  z-index: 10;
}

.content {
  color: #ffffff;
  user-select: none;
  font-size: 14px;
  text-align: center;
  padding: 4px;
}

.item:hover .filter {
  opacity: 1;
  transition: all .3s;
  cursor: pointer;
}

.quantity {
  transition: all .3s;
  position: absolute;
  right: 5px;
  bottom: 5px;
  user-select: none;
  cursor: pointer;
  font-size: 10px;
  color: black;
  background-color: rgb(230, 228, 228);
  padding: 4px;
  border-radius: 100%;
}

.item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  pointer-events:none;
  user-select: none;
}

</style>
