using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class PlacanjeAutoservisDijeloviInsert
    {
        public DateTime? Datum { get; set; }
        public double? Iznos { get; set; }
        public int? AutoservisId { get; set; }
        public int? FirmaAutodijelovaID { get; set; }
    }
}
