   --Reporte Solicitado por Melva G. para auditoria solicitada por Super Intendencia de Seguros.
   --Informacion de Corredores
   --  Armando Moreno M. 08/07/2019
   
   DROP procedure sp_super23;
   CREATE procedure sp_super23()
   RETURNING char(5), char(10), char(50), date, varchar(15), decimal(16,2);

	define _n_nombre_age	varchar(50);
	define _date_added,a_fecha_desde,a_fecha_hasta 		date;
	define _estatus         char(15);
	define _no_licencia     char(10);
	define _cod_agente      char(5);
	define _mto_bono,v_comision dec(16,2);
	define _valor 				smallint;
	
SET ISOLATION TO DIRTY READ;

let v_comision = 0.00;
let _mto_bono  = 0.00;

let a_fecha_desde = '01/05/2018';
let a_fecha_hasta = '31/05/2019';

--let _valor = sp_che04a('001', '001', a_fecha_desde , a_fecha_hasta);

FOREACH
	 select no_licencia,
	        nombre,
			date_added,
			decode(estatus_licencia,'A','Activo','P','Susp. Perm.','T','Susp. Temp.','X','Susp. Super'),
			cod_agente
	   into	_no_licencia,
			_n_nombre_age,
	        _date_added,
			_estatus,
			_cod_agente
   	   from agtagent
      where tipo_agente = 'A'
	    and cod_agente <> '00687'
	 order by nombre
	 
    let v_comision = 0;
	{SELECT SUM(comision)
	  INTO v_comision
	  FROM tmp_agente
     WHERE cod_agente = _cod_agente;}
	 
	select sum(comision)
	  into v_comision
	  from chqcomis
	 where cod_agente = _cod_agente
	   and fecha_desde >= a_fecha_desde
	   and fecha_hasta <= a_fecha_hasta;
	
	if v_comision is null then
		let v_comision = 0.00;
	end if

	return _cod_agente,_no_licencia, _n_nombre_age, _date_added, _estatus, v_comision with resume;
	
end foreach	
--drop table tmp_agente;
END PROCEDURE;