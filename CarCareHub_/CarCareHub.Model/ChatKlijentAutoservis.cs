using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ChatKlijentAutoservis
    {
        public int ChatKlijentAutoservisId { get; set; }

        // public int RazgovorId { get; set; }
        // public DateTime VrijemePocetka { get; set; }
        public DateTime VrijemeZadnjePoruke { get; set; }

        public virtual Klijent? Klijent { get; set; }
        public virtual int? KlijentId { get; set; }

        public int? AutoservisId { get; set; }
        public Autoservis? Autoservis { get; set; }
        //public virtual ICollection<Poruka> Poruka { get; set; }
    }
}
