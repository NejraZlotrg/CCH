using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{

public class ZaposlenikIzvjestaj
    {
        public int ZaposlenikId { get; set; }
        public string ImePrezime { get; set; }
        public decimal UkupanIznos { get; set; }
        public int BrojNarudzbi { get; set; }
        public decimal ProsjecnaVrijednost { get; set; }
        public List<ProizvodStatistika> NajpopularnijiProizvodi { get; set; }
        public string Autoservis { get; set; } // Added autoservice info
    }
}
