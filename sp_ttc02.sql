-- Procedimiento que carga tmp_asient, actualiza y borra.
-- 
-- Creado     :	17/03/2014 - Autor: Angel Tello	

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc02;		

create procedure "informix".sp_ttc02()
   returning integer, 
             char(100);


define _no_poliza   			 char(7);
define _no_endoso				 char(7);
--define _cod_ramo    			 char(3);
define _cuenta      			 char(25);
define _cod_origen				 char(3);
define _no_registro              integer;
define _error				  	 integer;
define _error_isam			     integer;
define _error_desc			     char(50);
define _fecha					 date;
define _no_remesa 				 char(10);
define _renglon					 smallint;
define _no_tranrec				 char(10);
define _no_reclamo				 char(10);
define _no_registroa             char(10);
define _nombre_ramo				 char(100);
define _nombre_origen			 char(25);
define _tabla_registro			 char(25);
define _band_cuenta				 char(25);
define _registo_r                integer;
define _cod_tipo_prod            char(3);
define _no_remesa1 				 char(10);
define _renglon1				 smallint;
define _no_requis				 char(10);
define _origen_cheque			 char(1);
define _chq_nombre_origen        char(50);			

 
set isolation to dirty read;

BEGIN WORK;
	begin 
	on exception set _error, _error_isam, _error_desc
		rollback work;
		return _error, _error_isam || " " || _error_desc;
	end exception

   { --cargar informacion de endasien
		let _no_registro =  1;
	
	delete 
	from deivid_ttcorp:tmp_asient
	where tabla_registro = 'endasien'   

	foreach	with hold
		
		select no_poliza,
			   no_endoso,
		       cuenta,
			   fecha
		  into _no_poliza,
		       _no_endoso,				
			   _cuenta,
			   _fecha
		  from endasien 
		 where year(fecha) = 2013
		 --where periodo = '2013-01'
		 

        select cod_ramo,
			   cod_origen,
			   cod_tipoprod
		  into _cod_ramo,
     		   _cod_origen,
			   _cod_tipo_prod
		  from emipomae
		 where no_poliza = 	_no_poliza; 

		insert into deivid_ttcorp:tmp_asient(no_registro_tabla, cod_ramo, cod_origen, cod_cuenta, tabla_registro, fecha, cod_tipoprod,no_poliza, no_endoso)
			values (_no_registro,_cod_ramo, _cod_origen, _cuenta, 'endasien',_fecha, _cod_tipo_prod, _no_poliza, _no_endoso   );

			let _no_registro = _no_registro + 1;
    end foreach}
	
 {  -- cargar informacion de cobasien
   let _no_registro = 1; 
	
	foreach
		
	    select no_remesa,
			   renglon,
		       cuenta,
			   fecha
		  into _no_remesa,
			   _renglon,
			   _cuenta,
			   _fecha
		  from cobasien 
		 where year(fecha) = 2013
		 
	   select no_poliza,
			  no_remesa,
			  renglon
         into _no_poliza,
			  _no_remesa1,
			  _renglon1
		 from cobredet
		where no_remesa = _no_remesa
		  and renglon = _renglon;
		 
	    if _no_poliza is  null then 
			continue foreach;
		end if 
			
		 select cod_ramo,
			   cod_origen,
			   cod_tipoprod
		  into _cod_ramo,
     		   _cod_origen,
			   _cod_tipo_prod
		  from emipomae
		 where no_poliza = 	_no_poliza; 

			insert into deivid_ttcorp:tmp_asient(no_registro_tabla, 
												 cod_ramo, 
												 cod_origen, 
												 cod_cuenta, 
												 tabla_registro, 
												 fecha,
												 cod_tipoprod,
												 no_poliza,
												 no_remesa,
												 renglon)
				                         values (_no_registro,
												 _cod_ramo, 
												 _cod_origen, 
												 _cuenta, 
												 'cobasien',
												 _fecha,
												 _cod_tipo_prod,
												 _no_poliza,
												 _no_remesa1,
												 _renglon1);

			let _no_registro = _no_registro + 1;			
				
	end foreach	}
	
 {  	-- cargar informacion de  recasien
	let _no_registro = 1; 
	
 foreach with hold		
		
		select no_tranrec,
			   cuenta,
			   fecha
		  into _no_tranrec,
		  	   _cuenta,
			   _fecha
		  from recasien 
		 where year(fecha) = 2013


		select no_reclamo 
          into _no_reclamo
		  from rectrmae
		 where no_tranrec = _no_tranrec;
		 
	    select no_poliza 
          into _no_poliza
		  from recrcmae
		 where no_reclamo = _no_reclamo;
			 
			 select cod_ramo,
			   cod_origen,
			   cod_tipoprod
		  into _cod_ramo,
     		   _cod_origen,
			   _cod_tipo_prod
		  from emipomae
		 where no_poliza = 	_no_poliza; 

		insert into deivid_ttcorp:tmp_asient( no_registro_tabla, 
											  cod_ramo,
											  cod_origen, 
											  cod_cuenta, 
											  tabla_registro,
											  fecha,
											  cod_tipoprod,
											  no_tranrec)
									values  ( _no_registro,
										   	  _cod_ramo, 
											  _cod_origen,
											  _cuenta, 
											  'recasien',
											  _fecha,
											  _cod_tipo_prod,
											  _no_tranrec);
 
			let _no_registro = _no_registro + 1;
		 
	end foreach	}
		
	-- cargar informacion de  chqchcta
   	let _no_registro = 1;

	delete 
	from deivid_ttcorp:tmp_asient
	where tabla_registro = 'chqchcta';   
   
    foreach with hold	
    		
		select no_requis,
		       cuenta,
			   fecha
		  into _no_requis,
			   _cuenta,
			   _fecha
		  from chqchcta 
		  where year(fecha) = 2013
		 --where periodo = '2013-01'
	  
		 
		 select origen_cheque
		  into _origen_cheque
		  from chqchmae
		 where no_requis = _no_requis; 		  

     
	    	insert into deivid_ttcorp:tmp_asient( no_registro_tabla,
	    										  cod_ramo, 
											      cod_origen, 
											      cod_cuenta, 
											      tabla_registro,
											      fecha)
									   values  ( _no_registro,
									   			 '', 
											     _origen_cheque,
											     _cuenta, 
											     'chqchcta',
											     _fecha);


			let _no_registro = _no_registro + 1;

	end foreach	
	
    -- cargar informacion de  reacomp
   	{let _no_registro = 1; 
    
    foreach with hold
     		
		select no_poliza,
		       no_registro,
			   fecha
		  into _no_poliza,
			   _no_registroa,
			   _fecha
		  from sac999:reacomp 
		 where year(fecha) = 2013

	  foreach
	   
		select cuenta 
		  into _cuenta
		  from sac999:reacompasie
		 where no_registro = _no_registroa

        select cod_ramo,
			   cod_origen
		  into _cod_ramo,
     		   _cod_origen
		  from emipomae
		 where no_poliza = _no_poliza; 

		insert into deivid_ttcorp:tmp_asient(no_registro_tabla, 
											 cod_ramo, 
											 cod_origen, 
											 cod_cuenta, 
											 tabla_registro,
											 fecha)
									values  (_no_registro,
											 _cod_ramo,
											 _cod_origen, 
											 _cuenta, 
											 'reacomp',
											 _fecha);

			let _no_registro = _no_registro + 1;
	 end foreach 	 
	end foreach}
end

COMMIT WORK;
 return 0, "Actualizacion Exitosa";

end procedure
