using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ChatKlijentServisInsert
    {
       //automatski
        public DateTime VrijemeZadnjePoruke { get; set; }


        public int? AutoservisId { get; set; }
        public int? KlijentId { get; set; }
       // public virtual ICollection<Poruka> Poruka { get; set; }
    }
}
