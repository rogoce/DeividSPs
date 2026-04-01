-- Procedimiento que trae el dia para restringir los registros de los indicadores
 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo078;		

create procedure "informix".sp_bo078(
a_periodo_act char(7),
a_periodo_ant char(7)
) returning date;

define _fecha			date;
define _periodo_fecha	char(7);
define _ano				smallint;
define _mes				smallint;
define _dia				smallint;

let _fecha = today;

let _periodo_fecha = sp_sis39(_fecha);

if _periodo_fecha > a_periodo_act then

	let _fecha = sp_sis36(a_periodo_ant);

else

	let _ano   = a_periodo_ant[1,4];	
	let _mes   = month(_fecha);
	let _dia   = day(_fecha);

------------------------------------------------------------------------------------
    If _mes = 2 Then
		If _dia > 28 Then
			let _dia = 28;
	        let	_fecha = MDY(_mes, _dia, _ano);
           
		else
			let _fecha = MDY(_mes, _dia, _ano);
		End If
	else
	   let _fecha = MDY(_mes, _dia, _ano);
	End If	
-------------------------------------------------------------------------------------

   --	let _fecha = MDY(_mes, _dia, _ano);

end if

return _fecha;

end procedure