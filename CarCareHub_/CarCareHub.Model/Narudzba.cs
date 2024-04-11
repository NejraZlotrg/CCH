using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Narudzba
    {
        public int NarudzbaId { get; set; }

        public int? NarudzbaStavkeId { get; set; }

        public DateTime? DatumNarudzbe { get; set; }

        public DateTime? DatumIsporuke { get; set; }

        public bool? ZavrsenaNarudzba { get; set; }

        public int? PopustId { get; set; }

        public virtual NarudzbaStavka? NarudzbaStavke { get; set; }

        public virtual Popust? Popust { get; set; }
    }
}
