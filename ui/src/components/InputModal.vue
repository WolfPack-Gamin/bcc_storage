<template>
    <div class="input-modal" v-show="showing">
        <div class="input-wrap">
            <div class="inputs">
                <div class="message">{{ message }}</div>
                <div class="value-button" id="decrease" @click="decrease">-</div>
                <input type="number" id="number" v-model="quantity" @keyup="formatQuantity" />
                <div class="value-button" id="increase" @click="increase">+</div>

                <div class="add-button" @click="emitItems">Add Item{{ quantity > 1 ? 's' : '' }}</div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'InputModal',
    props: {
        message: { type: String, requred: false, default: "How Many?" },
        showing: { type: Boolean, requred: false, default: false },
        max: { type: Number, requred: false, default: 10 },
    },
    data() {
        return {
            quantity: 1,
            min: 1
        }
    },
    emits: ['addItem'],
    watch: {
        showing(data) {
            if (!data) {
                this.quantity = 1
            }
        }
    },
    methods: {
        emitItems() {
            this.$emit('addItem', this.quantity)
        },
        formatQuantity() {
            if (this.quantity <= this.min - 1) {
                this.quantity = this.min
            }

            if (this.quantity > this.max) {
                this.quantity = this.max
            }
        },
        increase() {
            let value = this.quantity
            value = isNaN(value) ? this.min : value;

            if (value >= this.max) {
                value = this.max - 1
            }

            value++;
            this.quantity = value
        },
        decrease() {
            let value = this.quantity
            value = isNaN(value) ? this.min : value;
            value < this.min ? value = this.min : '';
            value--;
            value < this.min ? value = this.min : '';
            this.quantity = value
        }
    }
}
</script>


<style scoped>
.input-modal {
    background-image: url(../assets/bg.png);
    background-repeat: no-repeat;
    background-position: center;
    background-size: 100% 100%;
    height: 170px;
    width: 200px;
    position: absolute;
    top: 50%;
    left: 50%;
    border-radius: 2px;
    transform: translate(-50%, -50%);
}

.input-wrap {
    width: 300px;
    height: 80px;
    text-align: center;
    position: absolute;
    top: 30%;
    left: 50%;
    transform: translate(-50%, -30%);
}

.inputs {
    width: 300px;
    text-align: center;
}

.add-button {
    background-image: url(../assets/cta-bg.png);
    background-repeat: no-repeat;
    background-position: center;
    /* background-size: 100% 100%; */
    text-align: center;
    margin: 0 auto;
    margin-top: 8px;
    display: block;
    line-height: 100%;
    padding-top: 6px;
    padding-bottom: 6px;
    padding-left: 8px;
    padding-right: 8px;
    user-select: none;
    cursor: pointer;
    width: 100px;
    transition: all .3s;
}

.add-button:hover {
    opacity: .8;
    transition: all .3s;
}

.add-button:active {
    opacity: .6;
    transition: all .3s;
}

.message {
    margin-bottom: 4px;
}

.value-button {
    display: inline-block;
    border: 1px solid #948A8A;
    margin: 0px;
    width: 42px;
    height: 20px;
    margin-top: -4px;
    text-align: center;
    vertical-align: middle;
    padding: 11px 0;
    background: #948A8A;
    user-select: none;
    transition: all .3s;
}

#increase {
    border-top-right-radius: 2px;
    border-bottom-right-radius: 2px;
}

#decrease {
    border-top-left-radius: 2px;
    border-bottom-left-radius: 2px;
}

.value-button:hover {
    cursor: pointer;
    background-color: rgba(143, 70, 70, 0.618);
    border: 1px solid rgba(143, 70, 70, 0.618);
    transition: all .3s;
}

.value-button:active {
    background-color: rgba(94, 44, 44, 0.618);
    border: 1px solid rgba(143, 70, 70, 0.618);
    transition: all .3s;
}

input#number {
    display: inline-block;
    text-align: center;
    border: none;
    border-top: 1px solid #ddd;
    border-bottom: 1px solid #ddd;
    margin: 0px;
    width: 40px;
    height: 40px;
}

input[type=number]::-webkit-inner-spin-button,
input[type=number]::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
}
</style>
