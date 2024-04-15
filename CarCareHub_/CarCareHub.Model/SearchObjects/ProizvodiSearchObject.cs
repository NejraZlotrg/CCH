using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class ProizvodiSearchObject:BaseSearchObject
    {
        public bool? IsAllIncluded { get; set; }

        //Ali dodao
        public string? Naziv { get; set; } // Dodano svojstvo za pretragu po nazivu proizvoda

        public string? NazivFirme { get; set; }
        public string? JIB_MBS { get; set; }
        public string? NazivGrad { get; set; } // Novo svojstvo za pretragu po gradu firme


    }
}
