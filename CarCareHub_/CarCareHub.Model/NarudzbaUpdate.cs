using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class NarudzbaUpdate
    {

        public int? NarudzbaStavkeId { get; set; }

        public DateTime? DatumNarudzbe { get; set; }

        public DateTime? DatumIsporuke { get; set; }

        public bool? ZavrsenaNarudzba { get; set; }

        public int? PopustId { get; set; }

    }
}
