using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class FirmaAutodijelovaSearchObject : BaseSearchObject
    {
        public string? NazivFirme { get; set; }
        public string? Adresa { get; set; }
        public int? JIB { get; set; }
        public int? MBS { get; set; }
        public string? MarkaVozila { get; set; }
        public string? ModelVozila { get; set; }

        public int? GodisteVozila { get; set; }

        public bool IsAllncluded { get; set; }

    }
}
