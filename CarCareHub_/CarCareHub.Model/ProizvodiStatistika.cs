using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ProizvodStatistika
    {
        public int ProizvodId { get; set; }
        public string Naziv { get; set; }
        public int UkupnaKolicina { get; set; }
        public decimal UkupnaVrijednost { get; set; }
    }
}
