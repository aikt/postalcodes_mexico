namespace :envia_ya do
    desc "TODO"
    task generate_postal_codes: :environment do
        redis = Redis.new(host: "localhost")
        @ct = Country.where(code: 'MX').first
        ts = Time.now
        x = Roo::Excelx.new('./lib/assets/postal_codes.xlsx')
        x.sheets.drop(1).each do |st| # Remove sheet "Notas" and get each name of state
            st_p = st.parameterize
            unless st_id = redis.get(st_p) # Estados
                p "Load state: #{ st }"
                st_ft = { :name => st_p, :country_id => @ct.id }
                st_id = State.where(st_ft).first_or_create(st_ft).id.to_s
                redis.set(st_p,st_id)
            end
            x.sheet(st).column(6).drop(1).each_with_index do |ct,ct_i|
                ct_id, mp_id, pc_id = "", "", ""
                xs = x.sheet(st)
                mp, pc, nh = xs.column(4).drop(1)[ct_i], xs.column(1).drop(1)[ct_i], xs.column(2).drop(1)[ct_i]
                mp_p, pc_p, nh_p = mp.parameterize, pc.parameterize, nh.parameterize
                ct_p = ct.blank? ? mp_p : ct.parameterize
                st_ct = st_p+">>"+ct_p
                unless ct_id = redis.get(st_ct) # Ciudades
                    p "State: #{st} >> load city: #{ct}"
                    ct_ft = { :name => ct_p, :state_id => st_id, :country_id => @ct.id }
                    ct_id = City.where(ct_ft).create(ct_ft).id.to_s
                    redis.set(st_ct,ct_id)
                end
                st_ct_mp = st_ct+">>"+mp_p
                unless mp_id = redis.get(st_ct_mp) # Municipios
                    p "State: #{st} >> load municipality: #{mp}"
                    mp_ft = { :name => mp_p, :city_id => ct_id ,:state_id => st_id, :country_id => @ct.id }
                    mp_id = Municipality.where(mp_ft).create(mp_ft).id.to_s
                    redis.set(st_ct_mp,mp_id)
                end
                st_ct_mp_pc = st_ct_mp+">>"+pc
                unless pc_id = redis.get(st_ct_mp_pc) # Postal codes 
                    p "Postal code #{pc}"
                    pc_ft = { :code => pc , :municipality_id => mp_id, :state_id => st_id, :country_id => @ct.id }
                    pc_sl = PostalCode.where({ :code => pc, :country_id => @ct.id }).first_or_create(pc_ft)
                    pc_id = pc_sl.id.to_s
                    if pc_sl.state_id.to_s != st_id ||  pc_sl.municipality_id.to_s != mp_id
                        pc_sl.update({ :municipality_id => mp_id, :state_id => st_id })
                    end
                    redis.set(st_ct_mp_pc,pc_id)
                    ct_pc_ft = { :city_id => ct_id, :postal_code_id => pc_id }
                    CitiesPostalCode.where(ct_pc_ft).first_or_create(ct_pc_ft)
                end
                st_ct_mp_pc_nh = st_ct_mp_pc+">>"+nh_p
                unless nh_id = redis.get(st_ct_mp_pc_nh) # Colonias
                    p "Colonia #{ nh }"
                    nh_ft = { :name => nh, :postal_code_id => pc_id, :municipality_id => mp_id, :city_id => ct_id, :state_id => st_id, :country_id => @ct.id }
                    nh_sl = Neighborhood.where({ :name => nh, :postal_code_id => pc_id, :country_id => @ct.id}).first_or_create(nh_ft)
                    nh_id = nh_sl.id.to_s
                    if nh_sl.state_id.to_s != st_id || nh_sl.municipality_id.to_s != mp_id || nh_sl.city_id.to_s != ct_id
                        nh_sl.update({ :municipality_id => mp_id, :state_id => st_id, :city_id => ct_id})
                    end 
                    redis.set(st_ct_mp_pc_nh, nh_id)
                end
            end 
        end
        tf = Time.now

        puts "Hora de comienzo: #{ts.strftime("%I:%M:%S")}"
        puts "Finalizo #{tf.strftime("%I:%M:%S")}"
    end
  end
  