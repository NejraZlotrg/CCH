using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class BPAutodijeloviAutoservis
    {
        public int? BPAutodijeloviAutoservisId { get; set; }
        public virtual FirmaAutodijelova? FirmaAutodijelova { get; set; }
        public virtual Autoservis? Autoservis { get; set; }

        public int? FirmaAutodijelovaID { get; set; }
        public int? AutoservisId { get; set; }
        public bool Vidljivo { get; set; }
    }
}
