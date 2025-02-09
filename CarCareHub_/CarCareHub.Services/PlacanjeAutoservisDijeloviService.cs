using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{


    public class PlacanjeAutoservisDijeloviService : BaseCRUDService<Model.PlacanjeAutoservisDijelovi, Database.PlacanjeAutoservisDijelovi, PlacanjeAutoservisDijeloviSearchObject, PlacanjeAutoservisDijeloviInsert, PlacanjeAutoservisDijeloviUpdate>, IPlacanjeAutoservisDijeloviService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }

        public PlacanjeAutoservisDijeloviService(CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override Task<Model.PlacanjeAutoservisDijelovi> Insert(Model.PlacanjeAutoservisDijeloviInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.PlacanjeAutoservisDijelovi> Update(int id, Model.PlacanjeAutoservisDijeloviUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.PlacanjeAutoservisDijelovi> Delete(int id)
        {
            return await base.Delete(id);
        }


        public override IQueryable<Database.PlacanjeAutoservisDijelovi> AddInclude(IQueryable<Database.PlacanjeAutoservisDijelovi> query, PlacanjeAutoservisDijeloviSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.FirmaAutodijelova);
                query = query.Include(z => z.FirmaAutodijelova.Grad);
                query = query.Include(z => z.FirmaAutodijelova.Grad.Drzava);
                query = query.Include(z => z.Autoservis);
                query = query.Include(z => z.Autoservis.Grad);
                query = query.Include(z => z.Autoservis.Grad.Drzava);
               
            }
            return base.AddInclude(query, search);
        }

        //public static string GenerateSalt()
        //{
        //    RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
        //    var byteArray = new byte[16];
        //   provider.GetBytes(byteArray);


        //    return Convert.ToBase64String(byteArray);
        //}
        //public static string GenerateHash(string salt, string password)
        //{
        //    byte[] src = Convert.FromBase64String(salt);
        //    byte[] bytes = Encoding.Unicode.GetBytes(password);
        //    byte[] dst = new byte[src.Length + bytes.Length];

        //    System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
        //    System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

        //    HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
        //    byte[] inArray = algorithm.ComputeHash(dst);
        //    return Convert.ToBase64String(inArray);
        //}


    }
}






