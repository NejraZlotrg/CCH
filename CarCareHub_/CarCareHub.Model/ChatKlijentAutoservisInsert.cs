using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ChatKlijentAutoservisInsert
    {
       
        public DateTime VrijemeZadnjePoruke { get; set; }

        public virtual int? KlijentId { get; set; }

        public int? AutoservisId { get; set; }
    }
}
