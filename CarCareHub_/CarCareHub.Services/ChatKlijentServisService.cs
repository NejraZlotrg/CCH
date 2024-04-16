using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ChatKlijentServisService: BaseCRUDService<Model.ChatKlijentServis, Database.ChatKlijentServis, ChatKlijentServisSearchObject,
        ChatKlijentServisInsert, ChatKlijentServisUpdate>, IChatKlijentServisService
    {
        //private readonly ChatKlijentServis _chatKlijentServis;

        public ChatKlijentServisService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            //_chatKlijentServis = chatKlijentServis;
        }

        //public override async Task<List<ChatKlijentServis>> Get(ChatKlijentServisSearchObject search = null)
        //{
        //    IQueryable<Database.ChatKlijentServis> query = await base.Get(search);

        //    // Uključujemo povezane poruke samo ako je postavljen odgovarajući flag
        //    if (search?.IsAllIncluded == true)
        //    {
        //        query = AddInclude(query, search);
        //    }

        //    return query.ToList();
        //}
        //public async Task<List<Poruka>> GetPorukeByChatIdAsync(int chatId)
        //{
        //    // Pronađite chat po ID-u
        //    var chat = await CarCareHub.Services.Database.ChatKlijentServis
        //                               .Include(c => c.Poruka)
        //                               .FirstOrDefaultAsync(c => c.ChatKlijentServisId == chatId);

        //    if (chat == null)
        //    {
        //        // Ako chat nije pronađen, vratite praznu listu poruka
        //        return new List<Poruka>();
        //    }

        //    // Vratite listu poruka iz odabranog chata
        //    return chat.Poruka.ToList();
        //}


        //public async Task<List<Poruka>> GetPorukeByChatIdAsync(int chatId)
        //{
        //    // Pronađite čat po ID-u
        //    var chat = await _chatKlijentServis
        //                               .Include(c => c.Poruka) // Uključite povezane poruke
        //                               .FirstOrDefaultAsync(c => c.ChatKlijentServisId == chatId);

        //    if (chat == null)
        //    {
        //        // Ako čat nije pronađen, vratite praznu listu poruka
        //        return new List<Poruka>();
        //    }

        //    // Vratite listu poruka iz odabranog čata
        //    return chat.Poruka.ToList();
        //}

        public override IQueryable<Database.ChatKlijentServis> AddInclude(IQueryable<Database.ChatKlijentServis> query, ChatKlijentServisSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Autoservis);
                query = query.Include(z => z.Klijent);
                query = query.Include(z => z.Poruka);
            }
            return base.AddInclude(query, search);
        }

    }

}
