using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ChatKlijentZaposlenik
    {
        public int ChatKlijentServisId { get; set; }

        // public int RazgovorId { get; set; }
        // public DateTime VrijemePocetka { get; set; }
        public DateTime VrijemeZadnjePoruke { get; set; }

        public virtual Zaposlenik? Zaposlenik { get; set; }
        public virtual Klijent? Klijent { get; set; }

        public int? ZaposlenikId { get; set; }
        public int? KlijentId { get; set; }
        // public virtual ICollection<Poruka> Poruka { get; set; }
        //public virtual ICollection<Poruka> Poruka { get; set; }

    }
}
