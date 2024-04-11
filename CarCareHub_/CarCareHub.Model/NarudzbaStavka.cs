using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class NarudzbaStavka
    {
        public int NarudzbaStavkaId { get; set; }

        public int? ProizvodId { get; set; }

        public int? Kolicina { get; set; }

        public decimal? Cijena { get; set; }

        public virtual Proizvod? Proizvod { get; set; }
    }
}
