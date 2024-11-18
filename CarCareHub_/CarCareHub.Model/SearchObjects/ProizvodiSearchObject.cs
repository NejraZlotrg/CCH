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
        public string? NazivGrada { get; set; }// Novo svojstvo za pretragu po gradu firme

        public string? MarkaVozila { get; set; }  
        public int? GodisteVozila { get; set; }
        public string? ModelProizvoda { get; set; }  
        public int? KategorijaId { get; set; }
        public bool? CijenaOpadajuca { get; set; }
        public bool? CijenaRastuca { get; set; }
        public string? NazivModela { get; set; }

    }
}
