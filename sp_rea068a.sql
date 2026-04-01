-- Procedimiento que disminuye la reserva del reclamo y la aumenta

-- Creado    : 22/09/2015 - Autor: Armando Moreno

drop procedure sp_rea068a;

create procedure sp_rea068a()
returning integer,varchar(255);

define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _reserva_cob			dec(16,2);

DEFINE _cod_cobertura   	CHAR(5);  
DEFINE _cod_cliente     	CHAR(10); 
DEFINE _numrecla        	CHAR(18); 

DEFINE _no_tranrec_char 	CHAR(10); 
DEFINE _no_tran_char    	CHAR(10); 

DEFINE _version		    	CHAR(2);
DEFINE _aplicacion	    	CHAR(3);
DEFINE _valor_parametro 	CHAR(20);
DEFINE _valor_parametro2	CHAR(20);
DEFINE _fecha_no_server  	DATE;
DEFINE _periodo_rec     	CHAR(7);  

define _error				integer;
define _error_isam			integer;
define _error_desc			varchar(255);
define _no_poliza           char(10);
define _reserva		        decimal(16,2);
define _cod_ramo            char(3);
define _no_reclamo          char(10);
define _variacion_acum      dec(16,2);
define _variacion           dec(16,2);
define _reserva2            dec(16,2);
define _variacion_acum2     dec(16,2);
define _tipo_contrato       smallint;
define _cnt,_cnt2,_cnt3     smallint;
define _no_tranrec          char(10);
define _no_tranrec2         char(10);
define _transaccion			char(10);
define _transaccion2		char(10);
define _vigencia_inic       date;
define _cod_ruta            char(5);
define _porc_partic_prima	dec(9,6); 
define _porc_partic_suma	dec(9,6);
define _cod_contrato        char(5);
define _orden               smallint;
define _cod_cober_reas      char(3);
define _periodo,_periodo2   char(7);

set isolation to dirty read;

begin

foreach

		select t.no_tranrec, t.no_reclamo, t.periodo, t.transaccion
		  into _no_tranrec, _no_reclamo, _periodo, _transaccion
		  from rectrrea r, rectrmae t, reacomae m
		where r.no_tranrec = t.no_tranrec
		   and m.cod_contrato = r.cod_contrato
		   and t.actualizado = 1
		   and t.numrecla[1,2] in('02','23','20')
		   and r.cod_contrato not in('00647','00648','00649')
		   and t.periodo >= '2015-09'
		group by 1,2,3,4   
		order by 1

		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where no_reclamo = _no_reclamo;

        select cod_ramo,
               vigencia_inic
          into _cod_ramo,
               _vigencia_inic
          from emipomae
         where no_poliza = _no_poliza;		  
		   
		if _cod_ramo = '002' then
			let _cod_ruta = '00595';
		elif _cod_ramo = '023' then
			let _cod_ruta = '00597';
		elif _cod_ramo = '020' then
			let _cod_ruta = '00596';
		end if 
		
		select count(*)
		  into _cnt
		  from tranpen
		 where transaccion = _transaccion;
		 
		if _cnt is null then
			let _cnt = 0;
		end if
        if _cnt > 0 then
			continue foreach;
		end if
		
		if _vigencia_inic >= '01/07/2015' then
		
			call sp_rea065(_no_reclamo) returning _error, _error_desc;	--Crea Recreaco
		    if _error <> 0 then
				return _error, _no_tranrec || ' sp_rea065 ' || _error_desc with resume;
				continue foreach;
			end if
		    select count(*)
			  into _cnt3
			  from brectrref
			 where no_tranrec = _no_tranrec;
            if _cnt3 is null then
				let _cnt3 = 0;
			end if
		    if _cnt3 = 0 then
				insert into brectrref
				select * from rectrref where no_tranrec = _no_tranrec;
			end if	
			select count(*)
			  into _cnt3
			  from brectrrea
			 where no_tranrec = _no_tranrec;
            if _cnt3 is null then
				let _cnt3 = 0;
			end if
			if _cnt3 = 0 then
				insert into brectrrea
			    select * from rectrrea where no_tranrec = _no_tranrec;
			end if	
		
			delete from rectrref where no_tranrec = _no_tranrec;
			delete from rectrrea where no_tranrec = _no_tranrec;
			
			foreach
				select cod_contrato,
					   porc_partic_prima,
					   orden,
					   porc_partic_suma,
					   cod_cober_reas
				  into _cod_contrato,
					   _porc_partic_prima,
					   _orden,
					   _porc_partic_suma,
					   _cod_cober_reas
				  from rearucon
				 where cod_ruta = _cod_ruta
				 
				 select tipo_contrato
				   into _tipo_contrato
				   from reacomae
				  where cod_contrato = _cod_contrato; 

				insert into rectrrea(
							no_tranrec,
							orden,
							cod_contrato,
							porc_partic_suma,
							porc_partic_prima,
							tipo_contrato,
							cod_cober_reas)
				values(	_no_tranrec,
						_orden,
						_cod_contrato,
						_porc_partic_suma,
						_porc_partic_prima,
						_tipo_contrato,
						_cod_cober_reas);
			end foreach
			
			if _periodo >= '2015-09' then
				update rectrmae
				   set sac_asientos = 0
				 where no_tranrec = _no_tranrec;

				update sac999:reacomp
				   set sac_asientos  = 0
				 where no_tranrec    = _no_tranrec
				   and tipo_registro = 3;
			end if
			
		else
		    
			select count(*)
			  into _cnt2
			  from rec_pen
			 where no_reclamo = _no_reclamo;
            
            if _cnt2 is null then
				let _cnt2 = 0;
			end if
			
            if _cnt2 > 0 then
			
				{call sp_rea065(_no_reclamo) returning _error, _error_desc;	--Crea Recreaco
				if _error <> 0 then
					return _error, _no_reclamo || ' rec_pen, sp_rea065 ' || _error_desc with resume;
					continue foreach;
			    end if}
		
				foreach
						select t.no_tranrec,
							   t.transaccion,
							   t.periodo
						  into _no_tranrec2,
							   _transaccion2,
							   _periodo2
						  from rectrmae t
						 where t.actualizado = 1
						   and t.no_tranrec = _no_tranrec
						  						  
						select count(*)
						  into _cnt
						  from tranpen
						 where transaccion = _transaccion2;
						 
						if _cnt is null then
							let _cnt = 0;
						end if
					
						if _cnt > 0 then
							continue foreach;
						end if
						
						select count(*)
						  into _cnt3
						  from brectrref
						 where no_tranrec = _no_tranrec2;
						if _cnt3 is null then
							let _cnt3 = 0;
						end if
						if _cnt3 = 0 then
							insert into brectrref
							select * from rectrref where no_tranrec = _no_tranrec2;
						end if	
						select count(*)
						  into _cnt3
						  from brectrrea
						 where no_tranrec = _no_tranrec2;
						if _cnt3 is null then
							let _cnt3 = 0;
						end if
						if _cnt3 = 0 then
							insert into brectrrea
							select * from rectrrea where no_tranrec = _no_tranrec2;
						end if
						
						delete from rectrref where no_tranrec = _no_tranrec2;
						delete from rectrrea where no_tranrec = _no_tranrec2;
					
						foreach
							select cod_contrato,
								   porc_partic_prima,
								   orden,
								   porc_partic_suma,
								   cod_cober_reas
							  into _cod_contrato,
								   _porc_partic_prima,
								   _orden,
								   _porc_partic_suma,
								   _cod_cober_reas
							  from rearucon
							 where cod_ruta = _cod_ruta
							 
							 select tipo_contrato
							   into _tipo_contrato
							   from reacomae
							  where cod_contrato = _cod_contrato; 

							insert into rectrrea(
										no_tranrec,
										orden,
										cod_contrato,
										porc_partic_suma,
										porc_partic_prima,
										tipo_contrato,
										cod_cober_reas)
							values(	_no_tranrec2,
									_orden,
									_cod_contrato,
									_porc_partic_suma,
									_porc_partic_prima,
									_tipo_contrato,
									_cod_cober_reas);
						end foreach
						
						if _periodo2 >= '2015-09' then
							update rectrmae
							   set sac_asientos = 0
							 where no_tranrec = _no_tranrec2;

							update sac999:reacomp
							   set sac_asientos  = 0
							 where no_tranrec    = _no_tranrec2
							   and tipo_registro = 3;
						end if
						
				end foreach
			else
			
				call sp_rea070(_no_reclamo) returning _error, _error_desc;	--Crea Recreaco
				if _error <> 0 then
					return _error, _no_reclamo || ' 100% ret, sp_rea070 ' || _error_desc with resume;
					continue foreach;
			    end if
				
				select count(*)
				  into _cnt3
				  from brectrref
				 where no_tranrec = _no_tranrec;
				 
				if _cnt3 is null then
					let _cnt3 = 0;
				end if
				if _cnt3 = 0 then
					insert into brectrref
					select * from rectrref where no_tranrec = _no_tranrec;
				end if	
				select count(*)
				  into _cnt3
				  from brectrrea
				 where no_tranrec = _no_tranrec;
				if _cnt3 is null then
					let _cnt3 = 0;
				end if
				if _cnt3 = 0 then
					insert into brectrrea
					select * from rectrrea where no_tranrec = _no_tranrec;
				end if
				
				delete from rectrref where no_tranrec = _no_tranrec;
				delete from rectrrea where no_tranrec = _no_tranrec;

				if _cod_ramo = '002' then
					let _cod_ruta = '00598';
				elif _cod_ramo = '023' then
					let _cod_ruta = '00600';
				elif _cod_ramo = '020' then
					let _cod_ruta = '00599';
				end if
				
				foreach
					select cod_contrato,
						   porc_partic_prima,
						   orden,
						   porc_partic_suma,
						   cod_cober_reas
					  into _cod_contrato,
						   _porc_partic_prima,
						   _orden,
						   _porc_partic_suma,
						   _cod_cober_reas
					  from rearucon
					 where cod_ruta = _cod_ruta
					 
					 select tipo_contrato
					   into _tipo_contrato
					   from reacomae
					  where cod_contrato = _cod_contrato; 

					insert into rectrrea(
								no_tranrec,
								orden,
								cod_contrato,
								porc_partic_suma,
								porc_partic_prima,
								tipo_contrato,
								cod_cober_reas)
					values(	_no_tranrec,
							_orden,
							_cod_contrato,
							_porc_partic_suma,
							_porc_partic_prima,
							_tipo_contrato,
							_cod_cober_reas);
				end foreach
				if _periodo >= '2015-09' then
					update rectrmae
					   set sac_asientos = 0
					 where no_tranrec = _no_tranrec;

					update sac999:reacomp
					   set sac_asientos  = 0
					 where no_tranrec    = _no_tranrec
					   and tipo_registro = 3;
				end if
			end if
		end if	
end foreach

return 0,'Exito';
end
end procedure