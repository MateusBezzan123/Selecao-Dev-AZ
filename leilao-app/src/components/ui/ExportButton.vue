<template>
  <div class="export-dropdown">
    <button 
      @click="toggleDropdown" 
      class="btn-export"
      :class="{ 'has-data': hasData }"
      :disabled="!hasData"
    >
      <span class="btn-icon">📎</span>
      Exportar
      <span class="dropdown-arrow">▼</span>
    </button>
    
    <transition name="fade">
      <div v-if="isOpen" class="dropdown-menu">
        <button @click="exportToExcel" class="dropdown-item">
          <span class="item-icon">📊</span>
          Exportar para Excel
        </button>
        <button v-if="showPrint" @click="printReport" class="dropdown-item">
          <span class="item-icon">🖨️</span>
          Imprimir
        </button>
      </div>
    </transition>
  </div>
</template>

<script>
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

export default {
  name: 'ExportButton',
  props: {
    data: {
      type: Array,
      required: true
    },
    columns: {
      type: Array,
      required: true
    },
    filename: {
      type: String,
      default: 'relatorio'
    },
    title: {
      type: String,
      default: 'Relatório'
    },
    showPrint: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      isOpen: false
    }
  },
  computed: {
    hasData() {
      return this.data && this.data.length > 0
    }
  },
  methods: {
    toggleDropdown() {
      if (this.hasData) {
        this.isOpen = !this.isOpen
      }
    },
    
    closeDropdown() {
      this.isOpen = false
    },
    
    exportToExcel() {
      try {
        const worksheetData = [
          this.columns.map(col => col.label),
          ...this.data.map(row => 
            this.columns.map(col => {
              let value = this.getNestedValue(row, col.key)
              if (col.format === 'currency' && value) {
                return this.formatCurrency(value)
              }
              if (col.format === 'date' && value) {
                return this.formatDate(value)
              }
              return value || ''
            })
          )
        ]
        
        const ws = XLSX.utils.aoa_to_sheet(worksheetData)
        ws['!cols'] = this.columns.map(() => ({ wch: 20 }))
        
        const wb = XLSX.utils.book_new()
        XLSX.utils.book_append_sheet(wb, ws, this.title.substring(0, 31))
        
        const excelBuffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
        const data = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
        
        saveAs(data, `${this.filename}_${this.formatarDataHora()}.xlsx`)
        
        this.$emit('toast', { message: 'Relatório exportado para Excel com sucesso!', type: 'success' })
        this.closeDropdown()
      } catch (error) {
        console.error('Erro ao exportar Excel:', error)
        this.$emit('toast', { message: 'Erro ao exportar para Excel', type: 'error' })
      }
    },
    
    printReport() {
      try {
        const printWindow = window.open('', '_blank')
        
        const htmlContent = `
          <!DOCTYPE html>
          <html>
          <head>
            <title>${this.title}</title>
            <meta charset="UTF-8">
            <style>
              body {
                font-family: Arial, sans-serif;
                margin: 20px;
              }
              h1 {
                color: #333;
                text-align: center;
                margin-bottom: 10px;
              }
              .info {
                text-align: center;
                color: #666;
                margin-bottom: 20px;
                font-size: 12px;
              }
              table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
              }
              th {
                background: #4f46e5;
                color: white;
                padding: 10px;
                text-align: left;
                font-size: 12px;
              }
              td {
                padding: 8px;
                border-bottom: 1px solid #ddd;
                font-size: 11px;
              }
              tr:hover {
                background-color: #f5f5f5;
              }
              .footer {
                margin-top: 30px;
                text-align: center;
                font-size: 10px;
                color: #999;
                border-top: 1px solid #ddd;
                padding-top: 10px;
              }
              @media print {
                body {
                  margin: 0;
                  padding: 10px;
                }
                th {
                  background: #4f46e5;
                  print-color-adjust: exact;
                }
              }
            </style>
          </head>
          <body>
            <h1>${this.title}</h1>
            <div class="info">
              Gerado em: ${new Date().toLocaleString('pt-BR')}<br>
              Total de registros: ${this.data.length}
            </div>
            <table>
              <thead>
                <tr>
                  ${this.columns.map(col => `<th>${col.label}</th>`).join('')}
                </tr>
              </thead>
              <tbody>
                ${this.data.map(row => `
                  <tr>
                    ${this.columns.map(col => {
                      let value = this.getNestedValue(row, col.key)
                      if (col.format === 'currency' && value) {
                        value = this.formatCurrency(value)
                      }
                      if (col.format === 'date' && value) {
                        value = this.formatDate(value)
                      }
                      return `<td>${value || '-'}</td>`
                    }).join('')}
                  </tr>
                `).join('')}
              </tbody>
            </table>
            <div class="footer">
              Sistema de Gerenciamento de Leilões - Relatório gerado automaticamente
            </div>
            <script>
              window.onload = function() {
                window.print();
                setTimeout(function() { window.close(); }, 1000);
              }
            <\/script>
          </body>
          </html>
        `
        
        printWindow.document.write(htmlContent)
        printWindow.document.close()
        
        this.$emit('toast', { message: 'Preparando impressão...', type: 'info' })
        this.closeDropdown()
      } catch (error) {
        console.error('Erro ao imprimir:', error)
        this.$emit('toast', { message: 'Erro ao preparar impressão', type: 'error' })
      }
    },
    
    getNestedValue(obj, path) {
      return path.split('.').reduce((current, key) => {
        return current && current[key] !== undefined ? current[key] : ''
      }, obj)
    },
    
    formatCurrency(value) {
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
      }).format(value || 0)
    },
    
    formatDate(value) {
      if (!value) return ''
      const date = new Date(value)
      return date.toLocaleDateString('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    
    formatarDataHora() {
      const now = new Date()
      return now.toISOString().slice(0, 19).replace(/:/g, '-')
    }
  },
  
  mounted() {
    document.addEventListener('click', (e) => {
      if (!this.$el.contains(e.target)) {
        this.isOpen = false
      }
    })
  },
  
  beforeDestroy() {
    document.removeEventListener('click', this.closeDropdown)
  }
}
</script>

<style scoped>
.export-dropdown {
  position: relative;
  display: inline-block;
}

.btn-export {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: linear-gradient(135deg, #818cf8, #6366f1);
  color: white;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.2s;
}

.btn-export:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.btn-export:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-export.has-data:hover {
  background: linear-gradient(135deg, #6366f1, #4f46e5);
}

.dropdown-arrow {
  font-size: 0.7rem;
  margin-left: 4px;
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 8px;
  background: white;
  border-radius: 0.5rem;
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
  min-width: 200px;
  z-index: 1000;
  overflow: hidden;
  animation: slideDown 0.2s ease;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 10px 16px;
  background: white;
  border: none;
  cursor: pointer;
  text-align: left;
  transition: all 0.2s;
  font-size: 0.875rem;
  color: #374151;
}

.dropdown-item:hover {
  background: #f9fafb;
}

.item-icon {
  font-size: 1.1rem;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s;
}

.fade-enter,
.fade-leave-to {
  opacity: 0;
}

@media (max-width: 768px) {
  .btn-export {
    padding: 6px 12px;
    font-size: 0.75rem;
  }
  
  .dropdown-menu {
    min-width: 180px;
  }
  
  .dropdown-item {
    padding: 8px 12px;
    font-size: 0.8rem;
  }
}
</style>