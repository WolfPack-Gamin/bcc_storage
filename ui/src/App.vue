<template>
  <div>
    <div class="cont-content" v-show="showing" ref="draggableContainer">
      <div class="buttons">
        <mdicon class="drag" @mousedown="dragMouseDown" name="cursor-move" size="18" />
        <mdicon class="close" name="close-thick" size="18" @click="closeStorage" />
      </div>
      <Spinner :showing="spinnerload.active" :message="spinnerload.message"></Spinner>
      <InputModal :showing="howMany.active" :max="howMany.max" @addItem="continueMove"></InputModal>
      <div class="flex-container">
        <Inventory @toggleActive="handleActive" :dropzone="iactive" @onmoved="handleMoved" class="flex-child" :dev="dev"
          :disabled="disabled" header="satchel" type="inv" :inventory="playerinventory" />
        <Inventory @toggleActive="handleActive" :dropzone="sactive" @onmoved="handleMoved" class="flex-child" :dev="dev"
          :disabled="disabled" header="storage" type="str" :inventory="playerstorage" />
      </div>
    </div>
    <div class="dev" v-if="dev">
      <pre>Storage Active: {{ sactive }}</pre>
      <pre>Storage Active: {{ iactive }}</pre>
      <pre>Inventory: {{ playerinventory }}</pre>
      <pre>Storage: {{ playerstorage }}</pre>
    </div>
  </div>
</template>
<script>
// @ is an alias to /src
import Inventory from '@/components/Inventory.vue'
import Spinner from '@/components/Spinner.vue'
import InputModal from './components/InputModal.vue'

// Potentially replace with lodash/core to reduce bundle size by a bit
import { remove, cloneDeep, find } from 'lodash'


export default {
  name: 'HomeView',
  data() {
    return {
      dev: false,
      showing: false,
      entity: null,
      coords: {
        z: 0,
        y: 0,
        z: 0
      },
      playerinventory: [],
      playerstorage: [],
      sactive: false,
      iactive: false,
      disabled: false,
      spinnerload: {
        active: false,
        message: 'Saving Changes...'
      },
      howMany: {
        active: false,
        max: 1,
        qount: 1,
        mv: null
      },
      positions: {
        clientX: undefined,
        clientY: undefined,
        movementX: 0,
        movementY: 0
      },
      testdata: [
        {
          "limit": 10,
          "count": 1,
          "name": "ammorevolvernormal",
          "label": "Revolver Ammo Normal",
          "usable": true,
          "type": "item_standard"
        },
        {
          "limit": 10,
          "count": 6,
          "name": "water",
          "label": "Water",
          "usable": true,
          "type": "item_standard"
        },
        {
          "limit": 10,
          "count": 1,
          "name": "bread",
          "label": "Bread",
          "usable": true,
          "type": "item_standard"
        },
        {
          "limit": 10,
          "count": 1,
          "name": "book",
          "label": "Book",
          "usable": true,
          "type": "item_standard"
        }
      ]
    }
  },
  mounted() {
    window.addEventListener('message', this.onMessage);
    document.onmousemove = this.handleMouseMove;
    if (this.dev) {
      this.showing = true
      let temp = []
      for (let i = 0; i < 4; i++) {
        temp.push(this.testdata[i])
      }

      this.playerinventory = temp
    }
  },
  destroyed() {
    window.removeEventListener('message')
  },
  components: {
    Inventory,
    Spinner,
    InputModal
  },
  methods: {
    cleanData(data) {
      return data && data.replaceAll('\\', '').replaceAll('"[', '[').replaceAll(']"', ']')
    },
    onMessage(event) {
      if (event.data.type === 'bccopen') {
        this.playerstorage = []
        this.playerinventory = []
        let data = event.data

        let ps = this.cleanData(data.playerstorage)
        ps = JSON.parse(ps)

        let pi = JSON.parse(data.playerinventory)

        this.playerinventory = pi || []
        this.playerstorage =  ps || []
        this.entity = data.entity
        this.coords.x = data.x
        this.coords.y = data.y
        this.coords.z = data.z
        this.showing = true
      }

      if (event.data.type === 'bccstopspinner') {
        this.spinnerload.message = "Loading..."
        this.spinnerload.active = false
        this.disabled = false
        this.howMany = {
          active: false,
          max: 1,
          qount: 1,
          mv: null
        }
      }
    },
    handleActive(a) {
      let from = a.from
      if (from === 'str') {
        this.iactive = a.active
      } else if (from === 'inv') {
        this.sactive = a.active
      }
    },
    handleMoved(mv) {
      this.disabled = true
      this.howMany.active = true
      this.howMany.mv = mv
      this.howMany.max = mv.data.count

      if (mv.data.count === 1) {
        this.continueMove(1)
      }
    },
    continueMove(quantity) {
      let mv = this.howMany.mv

      this.spinnerload.message = "Saving Changes..."
      this.spinnerload.active = true
      
      let data = mv.data
      let to = mv.to
      let from = mv.from
      let tempadd = []
      let temprem = []
      let changes = {
        inv: {
          add: [],
          remove: []
        },
        str: {
          storage: [],
          add: [],
          remove: []
        }
      }

      // Remove FROM
      switch (from) {
        case "inv":
          temprem = cloneDeep(this.playerinventory)

          if (quantity < data.count) {
            let tdata = find(temprem, function(o) { 
              return o.label === data.label
            });
            tdata.count = tdata.count - quantity
          } else {
            remove(temprem, function (o) { return o.label === data.label });
          }

          data.count = quantity
          
          this.playerinventory = temprem
          changes.inv.remove.push(data)
          break;
        case "str":
          temprem = cloneDeep(this.playerstorage)

          if (quantity < data.count) {
            let tdata = find(temprem, function(o) { 
              return o.label === data.label
            });
            tdata.count = tdata.count - quantity 
          } else {
            remove(temprem, function (o) { return o.label === data.label });
          }

          data.count = quantity
          
          this.playerstorage = temprem          
          changes.str.remove.push(data)
          break;
        default:
          break;
      }

      // Add TO
      switch (to) {
        case "inv":
          tempadd = cloneDeep(this.playerinventory)
          
          let aData = find(tempadd, function(o) { 
              return o.label === data.label
          });

          if (aData) {
            aData.count += quantity
            data.count += quantity
          } else {
            tempadd.push(data)
          }
         
          this.playerinventory = tempadd
          changes.inv.add.push(data)
          break;
        case "str":
          tempadd = cloneDeep(this.playerstorage)
         
          let sData = find(tempadd, function(o) { 
              return o.label === data.label
          });

          if (sData) {
            sData.count += quantity
            data.count += quantity
          } else {
            tempadd.push(data)
          }

          this.playerstorage = tempadd
          changes.str.add.push(data)
          break;
        default:
          break;
      }

      changes.str.storage =  this.playerstorage

      // Store updates to server
      if (!this.dev) {
        fetch(`https://${GetParentResourceName()}/updateStorage`, {
          method: 'POST',
          body: JSON.stringify({
            changes: changes,
            coords: this.coords
          })
        });
      } else {
        this.spinnerload.message = "Loading..."
        this.spinnerload.active = false
        this.disabled = false


        this.howMany = {
          active: false,
          max: 1,
          qount: 1,
          mv: null
        }
      }
    },
    closeStorage() {
      this.showing = false
      fetch(`https://${GetParentResourceName()}/bccclose`, {
        method: 'POST',
        body: JSON.stringify({
          storage: this.entity
        })
      });
    },
    dragMouseDown: function (event) {
      event.preventDefault()
      // get the mouse cursor position at startup:
      this.positions.clientX = event.clientX
      this.positions.clientY = event.clientY
      document.onmousemove = this.elementDrag
      document.onmouseup = this.closeDragElement
    },
    elementDrag: function (event) {
      event.preventDefault()
      this.positions.movementX = this.positions.clientX - event.clientX
      this.positions.movementY = this.positions.clientY - event.clientY
      this.positions.clientX = event.clientX
      this.positions.clientY = event.clientY
      // set the element's new position:
      this.$refs.draggableContainer.style.top = (this.$refs.draggableContainer.offsetTop - this.positions.movementY) + 'px'
      this.$refs.draggableContainer.style.left = (this.$refs.draggableContainer.offsetLeft - this.positions.movementX) + 'px'
    },
    closeDragElement() {
      document.onmouseup = null
      document.onmousemove = null
    },
    handleMouseMove(event) {
      var eventDoc, doc, body;

      event = event || window.event; // IE-ism

      // If pageX/Y aren't available and clientX/Y are,
      // calculate pageX/Y.
      if (event.pageX == null && event.clientX != null) {
        eventDoc = (event.target && event.target.ownerDocument) || document;
        doc = eventDoc.documentElement;
        body = eventDoc.body;

        event.pageX = event.clientX +
          (doc && doc.scrollLeft || body && body.scrollLeft || 0) -
          (doc && doc.clientLeft || body && body.clientLeft || 0);
        event.pageY = event.clientY +
          (doc && doc.scrollTop || body && body.scrollTop || 0) -
          (doc && doc.clientTop || body && body.clientTop || 0);
      }
    }
  }
}
</script>
<style>
@font-face {
  font-family: rdr;
  src: url(assets/fonts/rdrlino-regular-webfont.woff);
}

@font-face {
  font-family: ancient;
  src: url(assets/fonts/AncientAd.ttf);
  font-weight: normal;
}

@font-face {
  font-family: cher;
  src: url(assets/fonts/Cherolina.ttf);
  font-weight: normal;
}

@font-face {
  font-family: wwi;
  src: url(assets/fonts/WWI.ttf);
  font-weight: normal;
}

#app {
  font-family: rdr;
  touch-action: manipulation;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #fff;
}

body {
  display: flex;
  flex-direction: column;
  justify-content: center;
  background-color: transparent;
  overflow: hidden;
}

.cont-content {
  background-size: cover;
  width: 65vw;
  max-height: 70vh;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  padding: 10px;
}

.dev {
  position: fixed;
  z-index: 9999;
  top: 0;
  left: 0;
  background: red;
  height: 100vh;
  width: 300px;
}

.flex-container {
  display: flex;
}

.flex-child {
  flex: 1;
}

.flex-child:first-child {
  margin-right: 45%;
}

/* width */
::-webkit-scrollbar {
  width: 6px;
}

/* Track */
::-webkit-scrollbar-track {
  background: rgb(126, 124, 124);
}

/* Handle */
::-webkit-scrollbar-thumb {
  background: rgb(165, 126, 126);
}

/* Handle on hover */
::-webkit-scrollbar-thumb:hover {
  background: rgb(143, 70, 70);
}

a {
  color: #efe1bd;
}

h2,
h3 {
  color: #c9c5c5;
  user-select: none;
}

.buttons {
  position: absolute;
  right: 5px;
  top: 5px;
  z-index: 999;
}

.drag {
  width: 28px;
  height: 28px;
  display: inline-block;
  padding: 0px 1px 1px 0px;
  text-align: center;
  user-select: none;
  color: #fff;
  cursor: pointer;
  background-color: black;
  border-radius: 100%;
  opacity: 0.4;
}

.close,
.drag {
  transition: all .3s;
  width: 28px;
  height: 28px;
  display: inline-block;
  padding: 0px 1px 2px 1px;

  text-align: center;
  user-select: none;
  color: #fff;
  cursor: pointer;
  background-color: black;
  border-radius: 100%;
  opacity: 0.4;
}

.drag {
  margin-right: 4px;
}

.drag:hover {
  transition: all .3s;
  background-color: #817c7c;
  opacity: 1;
}

.close:hover {
  transition: all .3s;
  background-color: #d31a13;
  opacity: 1;
}
</style>
