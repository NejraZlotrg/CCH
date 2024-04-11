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

            CreateMap<CarCareHub.Services.Database.Autoservis, Model.Autoservis>();
            CreateMap<Model.AutoservisUpdate, CarCareHub.Services.Database.Autoservis>();
            CreateMap<Model.AutoservisInsert, CarCareHub.Services.Database.Autoservis>();
            
            CreateMap<CarCareHub.Services.Database.Drzava, Model.Drzava>();
            CreateMap<Model.DrzavaUpdate, CarCareHub.Services.Database.Drzava>();
            CreateMap<Model.DrzavaInsert, CarCareHub.Services.Database.Drzava>();

            CreateMap<CarCareHub.Services.Database.FirmaAutodijelova, Model.FirmaAutodijelova>();
            CreateMap<Model.FirmaAutodijelovaInsert, CarCareHub.Services.Database.FirmaAutodijelova>();
            CreateMap<Model.FirmaAutodijelovaUpdate, CarCareHub.Services.Database.FirmaAutodijelova>();

            CreateMap<CarCareHub.Services.Database.Grad, Model.Grad>();
            CreateMap<Model.GradInsert, CarCareHub.Services.Database.Grad>();
            CreateMap<Model.GradUpdate, CarCareHub.Services.Database.Grad>();

            CreateMap<CarCareHub.Services.Database.Kategorija, Model.Kategorija>();
            CreateMap<Model.KategorijaInsert, CarCareHub.Services.Database.Kategorija>();
            CreateMap<Model.KategorijaUpdate, CarCareHub.Services.Database.Kategorija>();

            CreateMap<Database.Proizvod, Model.Proizvod>();
            CreateMap<Model.ProizvodiInsert, CarCareHub.Services.Database.Proizvod>();
            CreateMap<Model.ProizvodiUpdate, CarCareHub.Services.Database.Proizvod>();

            CreateMap<Database.Uloge, Model.Uloge>();
            CreateMap<Model.UlogeInsert, CarCareHub.Services.Database.Uloge>();
            CreateMap<Model.UlogeUpdate, CarCareHub.Services.Database.Uloge>();
           
            CreateMap<Database.Usluge, Model.Usluge>();
            CreateMap<Model.UslugeInsert, CarCareHub.Services.Database.Usluge>();
            CreateMap<Model.UslugeUpdate, CarCareHub.Services.Database.Usluge>();

           

            CreateMap<CarCareHub.Services.Database.Zaposlenik, Model.Zaposlenik>();
            CreateMap<Model.ZaposlenikUpdate, CarCareHub.Services.Database.Zaposlenik>();
            CreateMap<Model.ZaposlenikInsert, CarCareHub.Services.Database.Zaposlenik>();

            CreateMap<CarCareHub.Services.Database.Proizvodjac, Model.Proizvodjac>();
            CreateMap<Model.ProizvodjacUpdate, CarCareHub.Services.Database.Proizvodjac>();
            CreateMap<Model.ProizvodjacInsert, CarCareHub.Services.Database.Proizvodjac>();
            
            
            
            CreateMap<CarCareHub.Services.Database.Vozilo, Model.Vozilo>();
            CreateMap<Model.VoziloUpdate, CarCareHub.Services.Database.Vozilo>();
            CreateMap<Model.VoziloInsert, CarCareHub.Services.Database.Vozilo>();
            
            CreateMap<CarCareHub.Services.Database.Klijent, Model.Klijent>();
            CreateMap<Model.KlijentUpdate, CarCareHub.Services.Database.Klijent>();
            CreateMap<Model.KlijentInsert, CarCareHub.Services.Database.Klijent>();  
            
            CreateMap<CarCareHub.Services.Database.NarudzbaStavka, Model.NarudzbaStavka>();
            CreateMap<Model.NarudzbaStavkaUpdate, CarCareHub.Services.Database.NarudzbaStavka>();
            CreateMap<Model.NarudzbaStavkaInsert, CarCareHub.Services.Database.NarudzbaStavka>();

            CreateMap<CarCareHub.Services.Database.Popust, Model.Popust>();
            CreateMap<Model.PopustUpdate, CarCareHub.Services.Database.Popust>();
            CreateMap<Model.PopustInsert, CarCareHub.Services.Database.Popust>();

            CreateMap<CarCareHub.Services.Database.Narudzba, Model.Narudzba>();
            CreateMap<Model.NarudzbaUpdate, CarCareHub.Services.Database.Narudzba>();
            CreateMap<Model.NarudzbaInsert, CarCareHub.Services.Database.Narudzba>();

            //CreateMap< Model.Zaposlenik, CarCareHub.Services.Database.Zaposlenik>();

            // CreateMap<CarCareHub.Services.Database.FirmaAutodijelova, Model.FirmaAutodijelova>();
            // CreateMap<CarCareHub.Services.Database.FirmaAutodijelova, Model.FirmaAutodijelovaInsert>();

        }
    }
}
