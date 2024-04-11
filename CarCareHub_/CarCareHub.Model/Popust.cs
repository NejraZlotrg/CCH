using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Popust
    {
        public int PopustId { get; set; }

        public int? AutoservisId { get; set; }

        public int? FirmaAutodijelovaId { get; set; }

        public double? VrijednostPopusta { get; set; }

        public virtual Autoservis? Autoservis { get; set; }

        public virtual FirmaAutodijelova? FirmaAutodijelova { get; set; }

    }
}
