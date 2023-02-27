// Copyright EPFL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


#include <stddef.h>
#include <stdint.h>

#include "dma.h"
#include "dma_regs.h"  // Generated.

void dma_set_read_ptr(const dma_t *dma, uint32_t read_ptr) {
  mmio_region_write32(dma->base_addr, (ptrdiff_t)(DMA_PTR_IN_REG_OFFSET), read_ptr);
}

void dma_set_write_ptr(const dma_t *dma, uint32_t write_ptr) {
  mmio_region_write32(dma->base_addr, (ptrdiff_t)(DMA_PTR_OUT_REG_OFFSET), write_ptr);
}

void dma_set_cnt_start(const dma_t *dma, uint32_t copy_size) {
  mmio_region_write32(dma->base_addr, (ptrdiff_t)(DMA_DMA_START_REG_OFFSET), copy_size);
}

bool dma_get_done(const dma_t *dma) {
  return mmio_region_get_bit32(dma->base_addr, (ptrdiff_t)(DMA_DONE_REG_OFFSET), DMA_DONE_DONE_BIT);
}

bool dma_get_halfway(const dma_t *dma) {
    return mmio_region_get_bit32(dma->base_addr, (ptrdiff_t)(DMA_DONE_REG_OFFSET), DMA_DONE_HALFWAY_BIT);
}

void dma_set_read_ptr_inc(const dma_t *dma, uint32_t read_ptr_inc){
  mmio_region_write32(dma->base_addr, (ptrdiff_t)(DMA_SRC_PTR_INC_REG_OFFSET), read_ptr_inc);
}

void dma_set_write_ptr_inc(const dma_t *dma, uint32_t write_ptr_inc){
  mmio_region_write32(dma->base_addr, (ptrdiff_t)(DMA_DST_PTR_INC_REG_OFFSET), write_ptr_inc);
}

void dma_set_rx_wait_mode(const dma_t *dma, uint32_t peripheral_mask) {
  mmio_region_write32(dma->base_addr, (ptrdiff_t)(DMA_RX_WAIT_MODE_REG_OFFSET), peripheral_mask);
}

void dma_set_tx_wait_mode(const dma_t *dma, uint32_t peripheral_mask) {
  mmio_region_write32(dma->base_addr, (ptrdiff_t)(DMA_TX_WAIT_MODE_REG_OFFSET), peripheral_mask);
}


void dma_set_data_type(const dma_t *dma, uint32_t data_type){
  mmio_region_write32(dma->base_addr, (ptrdiff_t)(DMA_DATA_TYPE_REG_OFFSET), data_type);
}

void dma_enable_circular_mode(const dma_t *dma, bool enable) {
  mmio_region_write32(dma->base_addr, DMA_CIRCULAR_MODE_REG_OFFSET, enable << DMA_CIRCULAR_MODE_CIRCULAR_MODE_BIT);
}
