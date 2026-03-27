export default function getDisplayName(input: { githubOrg: string; githubEnt: string; githubTeam: string; scope: string }) {
    const teamName = input.githubTeam && input.githubTeam.trim() !== '' ? `| Team : ${input.githubTeam}` : '';
    const topLevelScope = input.githubEnt ? 'Enterprise' : 'Org';

    return `Copilot Metrics Viewer | ${topLevelScope} : ${input.githubOrg || input.githubEnt} ${teamName}`;
}
