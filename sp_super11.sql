   --Procedimiento de verificacion de data enviada por Mapfre pma. Asistencia.
   --  Armando Moreno M. 26/05/2017
   
   DROP procedure sp_super11;
   CREATE procedure sp_super11()
   RETURNING char(75),char(20),char(5),char(100),char(30),char(50),char(50),char(50);
   
   DEFINE _no_poliza     CHAR(10);
   define _no_documento  char(20);
   DEFINE _poliza        CHAR(100);
   define _numrecla      char(18);
   define _no_motor      char(30);
   define _no_unidad     char(5);
   define _cod_asegurado char(10);
   define _n_asegurado   char(75);
   define _fecha_reclamo date;
   define _fecha_siniestro date;
   define _periodo		 char(7);
   define _n_tipoveh     char(30);
   define _cnt           integer;
   define _placa         char(10);
   define _cod_marca     char(5);
   define _cod_modelo    char(5);
   define _n_marca       char(50);
   define _n_modelo      char(50);
   define _cod_tipoveh   char(3);
   
   
SET ISOLATION TO DIRTY READ;

foreach
	select distinct poliza,
	       placa,
		   no_motor,
		   cod_marca,
		   cod_modelo
	  into _poliza,
			_placa,
			_no_motor,
			_cod_marca,
			_cod_modelo
	  from mapfre_data m, emivehic e
     where m.poliza = e.no_chasis
	 --and m.poliza = '1'
     order by m.poliza
	 
	let _poliza = trim(_poliza);	--este es el numero de chasis
	 
		{foreach
			select placa,
				   no_motor,
				   cod_marca,
				   cod_modelo
			  into _placa,
				   _no_motor,
				   _cod_marca,
				   _cod_modelo
			  from emivehic
			 where no_chasis = _poliza}
		let _no_unidad = null;
		select nombre into _n_marca from emimarca where cod_marca = _cod_marca;
		select nombre into _n_modelo from emimodel where cod_modelo = _cod_modelo;
		let _no_unidad = null;
		foreach
			select no_unidad,
				   no_poliza,
				   cod_tipoveh
			  into _no_unidad,
				   _no_poliza,
				   _cod_tipoveh
			  from emiauto
			 where no_motor = _no_motor
			 
			 exit foreach;
		end foreach
		if _no_unidad is null then
			continue foreach;
		end if	
		select cod_contratante,no_documento into _cod_asegurado,_no_documento from emipomae	where no_poliza = _no_poliza;
		select nombre into _n_asegurado from cliclien where cod_cliente = _cod_asegurado;
		select nombre into _n_tipoveh from emitiveh where cod_tipoveh = _cod_tipoveh;
		
		return _n_asegurado,_no_documento,_no_unidad,_poliza,_no_motor,_n_tipoveh,_n_marca,_n_modelo with resume;

		--end foreach
	end foreach
END PROCEDURE;