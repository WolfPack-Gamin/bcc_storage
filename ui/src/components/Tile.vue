<template>
    <div class="item" :ref="'draggableItemContainer' + index" @mousedown="(e)=>dragStart(e, 'draggableItemContainer' + index,  index)">
        <div class="filter">
            <div class="content">
                {{item.label}}
            </div>
        </div>

        <div class="quantity">
            {{item.count}}/{{item.limit}}
        </div>
        <img v-if="item.name" :src="`nui://vorp_inventory/html/img/items/${item.name}.png`" :alt="item.label" loading="lazy"/>
    </div>
</template>

<script>

export default {
  name: 'Item',
  props: {
    item: { type: Object, requred: true},
    index: { type: Number, requred: true },
    sid: { type: String, requred: true },
    disabled: { type: Boolean, requred: false, default: false },
    dev: { type: Boolean, requred: false, default: false },
  },
  data () {
    return {
        positions: {
            clientX: undefined,
            clientY: undefined,
            movementX: 0,
            movementY: 0,
            initialStyle: undefined,
        },
        spots: {
            first: [1,5,9,13,17,21,25,29,33,37,41,45,49,53,57,61,65,69,73,77,81,85,89,93,97,101,105,109,113,117,121,125,129,133,137,141,145,149,153,157,161,165,169,173,177,181,185,189,193, 197],
            second: [2,6,10,14,18,22,26,30,34,38,42,46,50,54,58,62,66,70,74,78,82,86,90,94,98,102,106,110,114,118,122,126,130,134,138,142,146,150,154,158,162,166,170,174,178,182,186,190,194,198],
            third: [3,7,11,15,19,23,27,31,35,39,43,47,51,55,59,63,67,71,75,79,83,87,91,95,99,103,107,111,115,119,123,127,131,135,139,143,147,151,155,159,163,167,171,175,179,183,187,191,195,199],
            fourth: [4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100,104,108,112,116,120,124,128,132,136,140,144,148,152,156,160,164,168,172,176,180,184,188,192,196,200],
        }
    }
  },
  components: {
},
  watch: {

  },
  mounted () {
     
  },
  emits: ['onmoved', 'toggleActive'],
  methods: {
    dragStart(event, id, pos) {
        event.preventDefault()

        if (!this.disabled) {
          this.$emit('toggleActive', true)
          // get the mouse cursor position at startup:
          this.positions.clientX = event.clientX - 10
          this.positions.clientY = event.clientY

          this.positions.initialStyle = this.$refs[id].style
          // this.move(this.$refs[id], event.clientX, event.clientY)

          document.onmousemove = (e) => this.elementDrag(e, id, pos)
          document.onmouseup = (e) => this.dragEnd(e, id)
        }
    },
    elementDrag(event, id, pos) {
        event.preventDefault()

        let x = event.clientX
        let y = event.clientY

        let tpos = pos + 1
        // Every 1st spot 
        if (this.spots.first.includes(tpos)) {
            x = x - 200
        }
        // Every 2nd spot 
        if (this.spots.second.includes(tpos)) {
            x = x - 120
        }
        // Every 3rd spot 
        if (this.spots.third.includes(tpos)) {
            x = x - 50
        }
        // Every 4th spot 
        if (this.spots.fourth.includes(tpos)) {
  
        }

        this.positions.movementX = this.positions.clientX - x
        this.positions.movementY = this.positions.clientY - y
        this.positions.clientX = x
        this.positions.clientY = y
        this.move(this.$refs[id], this.positions.movementX, this.positions.movementY)
    },
    dragEnd (e, id) {
        this.$emit('toggleActive', false)
        this.positions.clientX = undefined
        this.positions.clientY = undefined
        this.positions.movementX = 0
        this.positions.movementY = 0

        document.onmouseup = null
        document.onmousemove = null
        


        let tid = e.target.id
        console.log(tid || 'None')
        console.log(e)


        if ((tid === 'str' || tid === 'inv') && this.sid != tid) {
            this.$emit('onmoved', {
                data: this.item,
                to: tid,
                from: this.sid
            })
            let ref = this.$refs[id]
            ref.style = this.positions.initialStyle   
        } else {
            let ref = this.$refs[id]
            ref.style = this.positions.initialStyle   
        }
    },
    move (ref, x, y) {
        ref.style.position = 'fixed'
        ref.style.top = (ref.offsetTop - y) + 'px'
        ref.style.left = (ref.offsetLeft - x) + 'px'
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
