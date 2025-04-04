using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class AutoservisIzvjestaj
    {
        public int AutoservisId { get; set; }
        public string NazivAutoservisa { get; set; }
        public decimal UkupanIznos { get; set; }
        public int BrojNarudzbi { get; set; }
        public decimal ProsjecnaCijena { get; set; }
        public List<ProizvodStatistika> NajpopularnijiProizvodi { get; set; } = new();
        public DateTime PeriodOd { get; set; } = DateTime.Now.AddDays(-30);
        public DateTime PeriodDo { get; set; } = DateTime.Now;
    }
}
