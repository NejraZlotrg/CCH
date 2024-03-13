using AutoMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class MappingProfile: Profile
    {

        public MappingProfile()
        {
            CreateMap<CarCareHub.Services.Database.Grad, Model.Grad>();
            CreateMap<CarCareHub.Services.Database.Zaposlenik, Model.Zaposlenik>();
           //CreateMap< Model.Zaposlenik, CarCareHub.Services.Database.Zaposlenik>();

           // CreateMap<CarCareHub.Services.Database.FirmaAutodijelova, Model.FirmaAutodijelova>();
           // CreateMap<CarCareHub.Services.Database.FirmaAutodijelova, Model.FirmaAutodijelovaInsert>();
            CreateMap<Model.FirmaAutodijelovaInsert, CarCareHub.Services.Database.FirmaAutodijelova>();
            CreateMap<Model.FirmaAutodijelovaUpdate, CarCareHub.Services.Database.FirmaAutodijelova>();

            CreateMap<Model.ProizvodiInsert, CarCareHub.Services.Database.Proizvod>();
            CreateMap<Model.ProizvodiUpdate, CarCareHub.Services.Database.Proizvod>();
            CreateMap<Model.ZaposlenikUpdate, CarCareHub.Services.Database.Zaposlenik>();
            CreateMap<Model.ZaposlenikInsert, CarCareHub.Services.Database.Zaposlenik>();
            CreateMap<Database.Uloge, Model.Uloge>();
            CreateMap<Database.Proizvod, Model.Proizvod>();





        }
    }
}
