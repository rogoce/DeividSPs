drop procedure sp_pro225;

create procedure "informix".sp_pro225(a_periodo char(7))
returning varchar(50) as ramo,
          varchar(50) as subramo,
          char(20)    as poliza,
		  date        as vigencia_inic,
		  date        as vigencia_final,
		  varchar(100) as descripcion,
		  smallint     as origen;

define _cod_ramo	 char(3);
define _cod_subramo  char(3);
define _cnt_pol_ren  integer;
define _cnt_vencidas integer;
define _origen       smallint;
define _no_poliza    char(10);
define _no_documento char(20);
define _vigencia_inic date;
define _vigencia_final date;
define _mes1         smallint;
define _ano1         smallint;
define _mes2         smallint;
define _ano2         smallint;
define _fecha1       date;
define _fecha2       date;
define _descrip      varchar(100);
define _desc_ramo    varchar(50);
define _desc_subramo varchar(50);
define _cnt          int;   
define _cod_subra_pol char(3);
define _cod_ramo_pol  char(3);

--SET DEBUG FILE TO "sp_sis83.trc";
--TRACE ON;


set isolation to dirty read;

let _cnt = 0;
let _mes1 = a_periodo[6,7];
let _ano1 = a_periodo[1,4];
let _mes2 = _mes1 + 1;
let _ano2 = _ano1;

IF _mes2 = 13 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
END IF

LET _fecha1 = MDY(_mes1,1,_ano1);
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

foreach
	select cod_ramo,
	       cod_subramo,
		   cnt_pol_ren,
		   cnt_vencidas,
		   origen
	  into _cod_ramo,
	       _cod_subramo,
		   _cnt_pol_ren,
		   _cnt_vencidas,
           _origen		   
	  from ramosubrh
     where periodo = a_periodo

    if _cnt_pol_ren > _cnt_vencidas then
	    if _cod_ramo = '019' then
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

		    SELECT nombre
			  INTO _desc_subramo
			  FROM prdsubra
			 WHERE cod_ramo    = _cod_ramo
			   AND cod_subramo = _cod_subramo;
		    
			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo
				   and origen = _origen
				   and periodo = a_periodo
				order by 2
				 
				if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
					select count(*) 
					  into _cnt
					  from emipomae
					 where no_documento = _no_documento
					   and no_poliza <> _no_poliza
					   and actualizado = 1;
					   
					if _cnt = 1 then  
						let _descrip = 'Poliza que se vencio del primer año y ahora son parte el grupo renovacion';
					else 
						let _descrip = '';
					end if				   
				else
					let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
				end if		
                return _desc_ramo,
                	   _desc_subramo,
                       _no_documento,	
                       _vigencia_inic,
                       _vigencia_final,
					   _descrip,
 					   _origen with resume;
			end foreach
		elif _cod_ramo = '004' then	
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;
			
			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo
				   and origen = _origen
				   and periodo = a_periodo
				order by 2
				   
				select count(*)
				  into _cnt
				  from emipouni 
				 where no_poliza = _no_poliza;
					 
 				if _cod_subramo = '001' then  
                    let _desc_subramo = 'INDIVIDUAL';				
					if _cnt = 1 then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				else
                    let _desc_subramo = 'GRUPO';				
					if _cnt > 1 then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				end if
			end foreach
		elif _cod_ramo = '018' then	
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			if _cod_subramo = '001' then  
				let _desc_subramo = 'INDIVIDUAL';				
			else 
			    let _desc_subramo = 'GRUPO';
			end if	
			return _desc_ramo,
				   _desc_subramo,
				   null,	
				   null,
				   null,
				   'Contactar a IT para corregir informe',
				   _origen with resume;			
		elif _cod_ramo = '016' then	
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;
			 
			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo
				   and origen = _origen
				   and periodo = a_periodo
				order by 2
				
				if _cod_subramo = '001' then
					if _cod_subra_pol <> '007' then
						let _desc_subramo = 'COLECTIVO DE VIDA';	
						
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				else
					if _cod_subra_pol = '007' then
					    let _desc_subramo = 'COLECTIVO DE DEUDA';
						
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				end if
			end foreach
		elif _cod_ramo = '001' then	
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo in ('001','021')
				   and origen = _origen
				   and periodo = a_periodo
				order by 2
				   
				if _cod_subramo = '001' then
					let _desc_subramo = 'RESIDENCIAL';
					if _cod_subra_pol = '001' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if	

						if month(_vigencia_inic) <> month(_vigencia_final) then
							--let _descrip = 'Se le hizo un endoso de aumento o disminución y se renovó en el mes';
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if
						
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
		            end if
				elif _cod_subramo = '002' then	
					let _desc_subramo = 'COMERCIAL';
					if _cod_subra_pol in ('002', '007') then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
		            end if
				else
					let _desc_subramo = 'INDUSTRIAL';
					if _cod_subra_pol in ('003','004','006') then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
		            end if
				end if
			end foreach
		elif _cod_ramo = '003' then
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;
			 
			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo
				   and origen = _origen
				   and periodo = a_periodo
				order by 2
				   
				if _cod_subramo = '001' then
					let _desc_subramo = 'RESIDENCIAL';
					if _cod_subra_pol = '001' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				else
					let _desc_subramo = 'COMERCIAL';
					if _cod_subra_pol <> '001' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
                end if
			end foreach
		elif _cod_ramo = '009' then
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;
			 
			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo
				   and origen = _origen
				   and periodo = a_periodo
				order by 2
				   
				if _cod_subramo = '002' then
					let _desc_subramo = 'TERRESTRE';
					if _cod_subra_pol in ('001','002','006','009') then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				elif _cod_subramo = '003' then
					let _desc_subramo = 'AEREO';
					if _cod_subra_pol = '003' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				else
					let _desc_subramo = 'MARITIMO';
					if _cod_subra_pol in ('004', '008') then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				end if
			end foreach
		elif _cod_ramo = '017' then
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

		    SELECT nombre
			  INTO _desc_subramo
			  FROM prdsubra
			 WHERE cod_ramo    = _cod_ramo
			   AND cod_subramo = _cod_subramo;
			 
			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo
				   and origen = _origen
				   and periodo = a_periodo
				   and cod_subramo = _cod_subramo
				order by 2
				   
				if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
					let _descrip = '';
				else
					let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
				end if		
				return _desc_ramo,
					   _desc_subramo,
					   _no_documento,	
					   _vigencia_inic,
					   _vigencia_final,
					   _descrip,
					   _origen with resume;
			end foreach	   
		elif _cod_ramo = '002' then
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo in ('002','020','023')
				   and origen = _origen
				   and periodo = a_periodo
				order by 2
				   
				if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
					let _descrip = '';
				else
					let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
				end if		
				return _desc_ramo,
					   _desc_ramo,
					   _no_documento,	
					   _vigencia_inic,
					   _vigencia_final,
					   _descrip,
					   _origen with resume;
			end foreach
		elif _cod_ramo = '010' then
			LET _desc_ramo = "RAMOS TECNICOS";

			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo,
					   cod_ramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol,
					   _cod_ramo_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo in ('011','012','013','014','007','022') 
				   and origen = _origen
				   and periodo = a_periodo
				order by 2

				if _cod_subramo = '001' then
					let _desc_subramo = 'TRC / TRM';
					if _cod_ramo_pol in ('013','014') then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				elif _cod_subramo = '002' then
					let _desc_subramo = 'EQUIPO ELECTRONICO';
					if _cod_ramo_pol = '010' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = 's';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				elif _cod_subramo = '003' then
					let _desc_subramo = 'CALDERA Y MAQUINARIA';
					if _cod_ramo_pol = '012' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				elif _cod_subramo = '004' then
					let _desc_subramo = 'ROTURA DE MAQUINARIA';
					if _cod_ramo_pol = '011' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				elif _cod_subramo = '005' then
					let _desc_subramo = 'EQUIPO PESADO';
 					if _cod_ramo_pol = '022' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
               else
					let _desc_subramo = 'VIDRIOS';
					if _cod_ramo_pol = '007' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
                end if
			end foreach
		elif _cod_ramo in ('006','026','027') then
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo,
					   cod_ramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol,
					   _cod_ramo_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo 
				   and origen = _origen
				   and periodo = a_periodo
				order by 2

				if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
					let _descrip = '';
				else
					let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
				end if		
				return _desc_ramo,
					   _desc_ramo,
					   _no_documento,	
					   _vigencia_inic,
					   _vigencia_final,
					   _descrip,
					   _origen with resume;
			end foreach
		
		elif _cod_ramo = '005' then
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo,
					   cod_ramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol,
					   _cod_ramo_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo 
				   and cod_subramo = '001'
				   and origen = _origen
				   and periodo = a_periodo
				order by 2

				if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
					let _descrip = '';
				else
					let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
				end if		
				return _desc_ramo,
					   _desc_ramo,
					   _no_documento,	
					   _vigencia_inic,
					   _vigencia_final,
					   _descrip,
					   _origen with resume;
			end foreach
		
		elif _cod_ramo = '008' then
		    SELECT nombre
			  INTO _desc_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo,
					   cod_ramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol,
					   _cod_ramo_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo 
				   and origen = _origen
				   and periodo = a_periodo
				order by 2

				if _cod_subramo = '001' then
					let _desc_subramo = 'OFERTA';
					if _cod_subra_pol in ('002','018') then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				elif _cod_subramo = '003' then
					let _desc_subramo = 'CUMPLIMIENTO';
					if _cod_subra_pol = '003' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				elif _cod_subramo = '004' then
					let _desc_subramo = 'CREDITO';
					if _cod_subra_pol = '012' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				elif _cod_subramo = '005' then
					let _desc_subramo = 'FIDELIDAD';
					if _cod_subra_pol = '009' then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				else
					let _desc_subramo = 'OTRAS';
					if _cod_subra_pol not in ('002','003','018') then
						if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
							let _descrip = '';
						else
							let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
						end if		
						return _desc_ramo,
							   _desc_subramo,
							   _no_documento,	
							   _vigencia_inic,
							   _vigencia_final,
							   _descrip,
							   _origen with resume;
					end if
				end if
			end foreach	
		elif _cod_ramo = '015' then
   			LET _desc_ramo = "OTROS";

		    SELECT nombre
			  INTO _desc_subramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			foreach
				select no_poliza,
					   no_documento,
					   vigencia_inic,
					   vigencia_final,
					   cod_subramo,
					   cod_ramo
				  into _no_poliza,
					   _no_documento,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_subra_pol,
					   _cod_ramo_pol
				  from estpolenh
				 where cod_endomov = '011'
				   and nueva_renov = 'R'
				   and cod_ramo = _cod_ramo 
				   and origen = _origen
				   and periodo = a_periodo
				order by 2

				if _vigencia_inic >= _fecha1 and _vigencia_inic <= _fecha2 then
					let _descrip = '';
				else
					let _descrip = 'Poliza que se vencio de un mes anterior renovada retroactivo';
				end if		
				return _desc_ramo,
					   _desc_subramo,
					   _no_documento,	
					   _vigencia_inic,
					   _vigencia_final,
					   _descrip,
					   _origen with resume;
			end foreach
		
		end if
	end if
	 
end foreach




end procedure
