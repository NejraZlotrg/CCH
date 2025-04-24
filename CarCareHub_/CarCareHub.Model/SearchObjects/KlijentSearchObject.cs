using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class KlijentSearchObject: BaseSearchObject
    {
        public string? Ime { get; set; }
        public string? Prezime { get; set; }
        public bool IsAllIncluded { get; set; }
    }
}
