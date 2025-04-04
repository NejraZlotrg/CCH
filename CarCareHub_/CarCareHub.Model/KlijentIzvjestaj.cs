using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{

    // Model za izvještaj

public class KlijentIzvjestaj
    {
        public int KlijentId { get; set; }
        public string ImePrezime { get; set; }
        public decimal UkupanIznos { get; set; }
        public int BrojNarudzbi { get; set; }
        public decimal ProsjecnaVrijednost { get; set; }
        public List<ProizvodStatistika> NajpopularnijiProizvodi { get; set; }
    }

}
