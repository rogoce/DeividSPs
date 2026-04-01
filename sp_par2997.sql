-- Procedimiento que carga la tabla actuario_2018 con el presupuesto enviado por el actuario

-- Creado    : 03/03/2017 - Autor: Federico Coronado 

drop procedure sp_par2997;

create procedure "informix".sp_par2997(a_ano char(4), a_cod_vendedor char(3) )
returning integer,
          char(50);

define _cod_agente		char(5);
define _cod_ramo		char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor varchar(100);
define _nombre_agente   varchar(100);
define _indicador       char(1);
define _nombre_ramo     varchar(50);
define _ene				dec(16,2);
define _feb				dec(16,2);
define _mar				dec(16,2);
define _abr				dec(16,2);
define _may				dec(16,2);
define _jun				dec(16,2);
define _jul				dec(16,2);
define _ago				dec(16,2);
define _sep				dec(16,2);
define _oct				dec(16,2);
define _nov				dec(16,2);
define _dic				dec(16,2);
define _cod_subramo     char(3);

--SET DEBUG FILE TO "sp_sp_par299.trc";      
--TRACE ON;     
                                                                

-- Se actualiza el codigo de vendedor 
--trace on;
-- Ventas Nuevas
/*
foreach
	select cod_agente
	  into _cod_agente
	  from deivid:agtagent
	 where cod_vendedor = a_cod_vendedor
	 
	 select nombre
	   into _nombre_vendedor
       from deivid:agtvende
      where cod_vendedor = a_cod_vendedor;  	   
	 
	 update deivid_bo:excel_actuario
		set cod_vendedor = a_cod_vendedor,
		    nombre_vendedor = _nombre_vendedor
	  where cod_agente = _cod_agente;
end foreach  
*/

let _nombre_ramo = " ";
let _nombre_agente = " ";

delete from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and ano = a_ano;

foreach
		select cod_vendedor, 
		       nombre_vendedor,
			   cod_agente, 
			   indicador,
			   cod_ramo,
			   cod_subramo,
			   sum(ene),
			   sum(feb),
			   sum(mar),
			   sum(abr), 
			   sum(may), 
			   sum(jun), 
			   sum(jul),
			   sum(ago), 
			   sum(sep),
			   sum(oct), 
			   sum(nov), 
			   sum(dic)
		 into _cod_vendedor,
			  _nombre_vendedor,
			  _cod_agente,
			  _indicador,
			  _cod_ramo,
			  _cod_subramo,
			  _ene,
		      _feb,
		      _mar,
		      _abr,
		      _may,
		      _jun,
		      _jul,
		      _ago,
		      _sep,
		      _oct,
		      _nov,
		      _dic	
	     from deivid_bo:excel_actuario
		where cod_vendedor = a_cod_vendedor
		  and indicador  = 'N'
		  and fronting	 = 'No'
	 group by 1,2,3,4,5,6
	 order by 1,3,6
	
	select nombre
      into _nombre_ramo
	  from deivid:prdramo
	 where cod_ramo = _cod_ramo;
	 
	select nombre
      into _nombre_agente
	  from deivid:agtagent
	 where cod_agente = _cod_agente;
	 
		 insert into deivid_bo:actuario_2018
		 values (_cod_vendedor, _nombre_vendedor, _cod_agente, _nombre_agente, _indicador, _cod_ramo, _nombre_ramo, _ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic, a_ano,_cod_subramo);
end foreach
-- Ventas Renovadas
foreach
		select cod_vendedor, 
		       nombre_vendedor,
			   cod_agente, 
			   indicador,
			   cod_ramo,
			   cod_subramo,
			   sum(ene),
			   sum(feb),
			   sum(mar),
			   sum(abr), 
			   sum(may), 
			   sum(jun), 
			   sum(jul),
			   sum(ago), 
			   sum(sep),
			   sum(oct), 
			   sum(nov), 
			   sum(dic)
		 into _cod_vendedor,
			  _nombre_vendedor,
			  _cod_agente,
			  _indicador,
			  _cod_ramo,
			  _cod_subramo,
			  _ene,
		      _feb,
		      _mar,
		      _abr,
		      _may,
		      _jun,
		      _jul,
		      _ago,
		      _sep,
		      _oct,
		      _nov,
		      _dic	
	     from deivid_bo:excel_actuario
		where cod_vendedor = a_cod_vendedor
		  and indicador  = 'R'
		  and fronting	 = 'No'
	 group by 1,2,3,4,5,6
	 order by 1,3,6
	 
	select nombre
      into _nombre_ramo
	  from deivid:prdramo
	 where cod_ramo = _cod_ramo;
	 
	select nombre
      into _nombre_agente
	  from deivid:agtagent
	 where cod_agente = _cod_agente;
	 
		 insert into deivid_bo:actuario_2018
		 values (_cod_vendedor, _nombre_vendedor, _cod_agente, _nombre_agente, _indicador, _cod_ramo, _nombre_ramo, _ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic, a_ano,_cod_subramo);
end foreach

return 0, "Actualizacion Exitosa";

end procedure


