--Reportes de detalle de RRC y Partcipacion saldo del mes
--Armando Moreno M.    23/07/2025

drop procedure sp_reserva_riesgo3;
create procedure sp_reserva_riesgo3(a_periodo char(7))
returning smallint   as tipo,
          smallint   as orden,
		  char(3)    as cod_ramo,
		  varchar(50) as n_ramo,
		  char(12)    as cuenta,
		  varchar(50) as n_cuenta,
		  dec(16,2)   as debito,
		  dec(16,2)   as credito;

BEGIN

define _cod_subramo         		char(3);
define _cod_ramo   					char(3);
define _rrc_cedida,_rrc_100,_db,_cr,_saldo dec(16,2);
define _tipo,_orden,_mes,_ano,_valor        smallint;
define _n_ramo,_cta_nombre          varchar(50);
define _cuenta                      char(12);
define _periodo_ant                 char(7);


--set debug file to "sp_reserva_riesgo1.trc";
--trace on;

set isolation to dirty read;

drop table if exists tmp_mov_cuentas;

let _rrc_100    = 0.00;
let _rrc_cedida = 0.00;
let _saldo      = 0;

--***INICIALIZAR TABLA DE SALIDA***
update deivid_ttcorp:detalle_rrc_part
   set db = 0,
       cr = 0;
	   
--***SACAR EL PERIODO ANTERIOR
let _ano = a_periodo[1,4];
let _mes = a_periodo[6,7];
if _mes = 1 then
	let _ano = _ano - 1;
	let _periodo_ant = _ano || "-12";
else
    if _mes < 10 then
		let _periodo_ant = _ano || "-0" || _mes - 1;
	else
		let _periodo_ant = _ano || "-" || _mes - 1;
	end if
end if

--*******PRIMER CUADRO RRC PARTICIPACION, PERIODO ANTERIOR
foreach
	select cod_ramo,
	       sum(rrc_cedida)
	  into _cod_ramo,
	       _rrc_cedida
	  from deivid_ttcorp:reserva_riesgo_curso
     where periodo = _periodo_ant
	 group by cod_ramo
	 order by cod_ramo
	
	if _rrc_cedida is null then
		let _rrc_cedida = 0.00;
	end if
	if _cod_ramo in('020','023') then
		let _cod_ramo = '002';
	elif _cod_ramo in('001','003') then
		let _cod_ramo = '001';
    elif _cod_ramo in('010','013','012','011','022','007','021','014') then --ramos tecnicos
		let _cod_ramo = 'RTE';
	elif _cod_ramo = '017' then --Casco
		let _rrc_cedida = 0.00;
		foreach
			select decode(e.cod_subramo,'001','MAR','002','AER'),
			       sum(rrc_cedida)
			  into _cod_subramo,
			       _rrc_cedida
			  from deivid_ttcorp:reserva_riesgo_curso t, emipoliza e
		     where t.id_poliza = e.no_documento
               and t.periodo = _periodo_ant
               and t.cod_ramo = _cod_ramo
               and e.cod_subramo in('002','001') --aereo,maritimo
          group by e.cod_subramo
		  
			update deivid_ttcorp:detalle_rrc_part
			   set db = _rrc_cedida,
			       cr = 0
			 where cod_ramo = _cod_subramo
			   and tipo = 1
			   and orden = 1;
	   
			update deivid_ttcorp:detalle_rrc_part
			   set db = 0,
				   cr = _rrc_cedida
			 where cod_ramo = _cod_subramo
			   and tipo = 1
			   and orden = 2;
			   
		end foreach
	end if
	
	if _cod_ramo <> '017' then
		update deivid_ttcorp:detalle_rrc_part
		   set db = db + _rrc_cedida,
			   cr = 0
		 where cod_ramo = _cod_ramo
		   and tipo = 1
		   and orden = 1;
		   
		update deivid_ttcorp:detalle_rrc_part
		   set db = 0,
			   cr = cr + _rrc_cedida
		 where cod_ramo = _cod_ramo
		   and tipo = 1
		   and orden = 2;
	end if
	   
END foreach
--*******PRIMER CUADRO RRC PARTICIPACION, PERIODO ACTUAL
foreach
	select cod_ramo,
	       sum(rrc_cedida)
	  into _cod_ramo,
	       _rrc_cedida
	  from deivid_ttcorp:reserva_riesgo_curso
     where periodo = a_periodo
	 group by cod_ramo
	 order by cod_ramo
	
	if _rrc_cedida is null then
		let _rrc_cedida = 0.00;
	end if
	if _cod_ramo in('020','023') then
		let _cod_ramo = '002';
	elif _cod_ramo in('001','003') then
		let _cod_ramo = '001';
    elif _cod_ramo in('010','013','012','011','022','007','021','014') then --ramos tecnicos
		let _cod_ramo = 'RTE';
	elif _cod_ramo = '017' then --Casco
		let _rrc_cedida = 0.00;
		foreach
			select decode(e.cod_subramo,'001','MAR','002','AER'),
			       sum(rrc_cedida)
			  into _cod_subramo,
			       _rrc_cedida
			  from deivid_ttcorp:reserva_riesgo_curso t, emipoliza e
		     where t.id_poliza = e.no_documento
               and t.periodo = a_periodo
               and t.cod_ramo = _cod_ramo
               and e.cod_subramo in('002','001') --aereo,maritimo
          group by e.cod_subramo
		  
			update deivid_ttcorp:detalle_rrc_part
			   set db = db - _rrc_cedida,
			       cr = 0
			 where cod_ramo = _cod_subramo
			   and tipo = 1
			   and orden = 1;
	   
			update deivid_ttcorp:detalle_rrc_part
			   set db = 0,
				   cr = cr - _rrc_cedida
			 where cod_ramo = _cod_subramo
			   and tipo = 1
			   and orden = 2;
			   
		end foreach
	end if
	
	if _cod_ramo <> '017' then
		update deivid_ttcorp:detalle_rrc_part
		   set db = db - _rrc_cedida,
			   cr = 0
		 where cod_ramo = _cod_ramo
		   and tipo = 1
		   and orden = 1;
		   
		update deivid_ttcorp:detalle_rrc_part
		   set db = 0,
			   cr = cr - _rrc_cedida
		 where cod_ramo = _cod_ramo
		   and tipo = 1
		   and orden = 2;
	end if
end foreach
--*******SEGUNDO CUADRO RRC 100%, PERIODO ANTERIOR
foreach
	select cod_ramo,
	       sum(rrc_100)
	  into _cod_ramo,
	       _rrc_100
	  from deivid_ttcorp:reserva_riesgo_curso
     where periodo = _periodo_ant
	 group by cod_ramo
	 order by cod_ramo
	 
	if _cod_ramo in('020','023') then
		let _cod_ramo = '002';
    elif _cod_ramo in('001','003') then
		let _cod_ramo = '001';
    elif _cod_ramo in('010','013','012','011','022','007','021','014') then --ramos tecnicos
		let _cod_ramo = 'RTE';
	elif _cod_ramo = '017' then --Casco
		let _rrc_100 = 0.00;
		foreach
			select decode(e.cod_subramo,'001','MAR','002','AER'),
			       sum(rrc_100)
			  into _cod_subramo,
			       _rrc_100
			  from deivid_ttcorp:reserva_riesgo_curso t, emipoliza e
		     where t.id_poliza = e.no_documento
               and t.periodo = _periodo_ant
               and t.cod_ramo = _cod_ramo
               and e.cod_subramo in('002','001') --aereo,maritimo
          group by e.cod_subramo
		  
			update deivid_ttcorp:detalle_rrc_part
			   set db = 0,
				   cr = _rrc_100
			 where cod_ramo = _cod_subramo
			   and tipo = 2
			   and orden = 3;
			   
			update deivid_ttcorp:detalle_rrc_part
			   set db = _rrc_100,
				   cr = 0
			 where cod_ramo = _cod_subramo
			   and tipo = 2
			   and orden = 4;
			   
		end foreach
	end if
	
	if _cod_ramo <> '017' then
		update deivid_ttcorp:detalle_rrc_part
		   set db = 0,
			   cr = cr + _rrc_100
		 where cod_ramo = _cod_ramo
		   and tipo = 2
		   and orden = 3;
		   
		update deivid_ttcorp:detalle_rrc_part
		   set db = db + _rrc_100,
			   cr = 0
		 where cod_ramo = _cod_ramo
		   and tipo = 2
		   and orden = 4;
	end if
END foreach
--*******SEGUNDO CUADRO RRC 100%, PERIODO ACTUAL
foreach
	select cod_ramo,
	       sum(rrc_100)
	  into _cod_ramo,
	       _rrc_100
	  from deivid_ttcorp:reserva_riesgo_curso
     where periodo = a_periodo
	 group by cod_ramo
	 order by cod_ramo
	 
	if _cod_ramo in('020','023') then
		let _cod_ramo = '002';
    elif _cod_ramo in('001','003') then
		let _cod_ramo = '001';
    elif _cod_ramo in('010','013','012','011','022','007','021','014') then --ramos tecnicos
		let _cod_ramo = 'RTE';
	elif _cod_ramo = '017' then --Casco
		let _rrc_100 = 0.00;
		foreach
			select decode(e.cod_subramo,'001','MAR','002','AER'),
			       sum(rrc_100)
			  into _cod_subramo,
			       _rrc_100
			  from deivid_ttcorp:reserva_riesgo_curso t, emipoliza e
		     where t.id_poliza = e.no_documento
               and t.periodo = a_periodo
               and t.cod_ramo = _cod_ramo
               and e.cod_subramo in('002','001') --aereo,maritimo
          group by e.cod_subramo
		  
			update deivid_ttcorp:detalle_rrc_part
			   set db = 0,
				   cr = cr - _rrc_100
			 where cod_ramo = _cod_subramo
			   and tipo = 2
			   and orden = 3;
			   
			update deivid_ttcorp:detalle_rrc_part
			   set db = db - _rrc_100,
				   cr = 0
			 where cod_ramo = _cod_subramo
			   and tipo = 2
			   and orden = 4;
			   
		end foreach
	end if
	
	if _cod_ramo <> '017' then
		update deivid_ttcorp:detalle_rrc_part
		   set db = 0,
			   cr = cr - _rrc_100
		 where cod_ramo = _cod_ramo
		   and tipo = 2
		   and orden = 3;
		   
		update deivid_ttcorp:detalle_rrc_part
		   set db = db - _rrc_100,
			   cr = 0
		 where cod_ramo = _cod_ramo
		   and tipo = 2
		   and orden = 4;
	end if
END foreach

--SALIDA
foreach
	select cod_ramo,
	       cuenta,
		   db,
		   cr,
		   tipo,
		   orden
	  into _cod_ramo,
	       _cuenta,
		   _db,
		   _cr,
		   _tipo,
		   _orden
      from deivid_ttcorp:detalle_rrc_part
	 order by tipo,orden
	
	if _cod_ramo = 'MAR' then
		let _n_ramo = 'CASCO MARITIMO';
		
	elif _cod_ramo = 'AER' then
		let _n_ramo = 'CASCO AEREO';
		
	elif _cod_ramo = 'RTE' then
		let _n_ramo = 'RAMOS TECNICOS';
		
	else	
		select nombre into _n_ramo from prdramo
		where cod_ramo = _cod_ramo;
	end if	
	
	select cta_nombre
	  into _cta_nombre
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	return _tipo,_orden,_cod_ramo,_n_ramo,_cuenta,_cta_nombre,_db,_cr with resume;

end foreach
end			
end procedure;