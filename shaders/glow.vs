//shader -little mia_inscinerator_glow glow.vs glow.ps mia_inscinerator_glow.ksh -oglsl
//shader -little mia_inscinerator_ember glow.vs ember.ps mia_inscinerator_ember.ksh -oglsl
attribute vec3 POSITION;
attribute vec2 TEXCOORD0;

varying vec2 PS_TEXCOORD0;

void main()
{
	gl_Position = vec4( POSITION.xyz, 1.0 );
	PS_TEXCOORD0.xy = TEXCOORD0.xy;
}