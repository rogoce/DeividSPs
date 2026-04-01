-- Procedimiento que disminuye la reserva del reclamo y la aumenta

-- Creado    : 22/09/2015 - Autor: Armando Moreno

drop procedure sp_rea068;

create procedure sp_rea068()
returning integer,char(10);

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
define _error_desc			char(50);
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
define _periodo             char(7);
define _mensaje             char(50);

set isolation to dirty read;

begin

foreach
		select r.no_reclamo,
		       r.no_tranrec,
		       r.transaccion,
			   r.periodo,
			   e.vigencia_inic,
			   e.cod_ramo
		  into _no_reclamo,
		       _no_tranrec,
			   _transaccion,
			   _periodo,
			   _vigencia_inic,
			   _cod_ramo
          from rectrmae r, recrcmae t, emipomae e
         where r.no_reclamo = t.no_reclamo
           and t.no_poliza = e.no_poliza
           and r.actualizado = 1
           and r.periodo >= '2015-07'
           and e.cod_ramo in('002','023','020')
           order by e.cod_ramo,r.no_reclamo
		   
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

			call sp_rea065(_no_reclamo) returning _error, _error_desc;	--Crea Recreaco
			call sp_sis58bk(_no_tranrec) returning _error, _mensaje;	--Crea Rectrrea

			if _error <> 0 then
				return _error, _mensaje;
			end if
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
		
				foreach
						select t.no_tranrec,
							   t.transaccion,
							   t.periodo
						  into _no_tranrec2,
							   _transaccion2,
							   _periodo2
						  from rectrmae t, rec_pen r
						 where t.no_reclamo = r.no_reclamo
						   and t.actualizado = 1
						   and t.periodo >= '2015-07'
						   and r.no_reclamo = _no_reclamo
						  order by 1,2
						  
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

						call sp_rea065(_no_reclamo) returning _error, _error_desc;	--Crea Recreaco
						call sp_sis58bk(_no_tranrec2) returning _error, _mensaje;	--Crea Rectrrea

						if _error <> 0 then
							return _error, _mensaje;
						end if
						if _periodo >= '2015-09' then
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
				
				call sp_rea070(_no_reclamo) returning _error, _error_desc;	--Crea Recreaco
				call sp_sis58bk(_no_tranrec) returning _error, _mensaje;	--Crea Rectrrea

				if _error <> 0 then
					return _error, _mensaje;
				end if
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