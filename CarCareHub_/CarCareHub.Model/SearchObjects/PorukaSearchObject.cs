using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class PorukaSearchObject: BaseSearchObject
    {
        public bool? IsAllIncluded { get; set; }
        public string? Sadrzaj { get; set; }
        public int? ChatKlijentZaposlenikId { get; set; } // ID razgovora kojem poruka pripada
        public int? ChatKlijentAutoservisId { get; set; } // ID razgovora kojem poruka pripada


    }
}
